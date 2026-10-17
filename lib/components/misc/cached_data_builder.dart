import 'package:flutter/material.dart';

import '../../services/response_cache.dart';

/// A [FutureBuilder] replacement for cached API data, which paints what is
/// already cached in its very first frame.
///
/// [FutureBuilder] always begins in the waiting state, so a screen whose data
/// is cached still shows its skeleton for as long as the read and decode take —
/// on the ~850 KB people-group list, long enough to look like a fresh fetch.
/// This widget instead peeks the in-memory cache synchronously in [initState]:
/// when a value is there the skeleton is never built at all, and the fetch that
/// runs alongside it only repaints if it comes back with something different.
/// The skeleton appears only when there is genuinely nothing to show yet.
///
/// It also listens for background revalidations of [cacheKey], so a screen
/// painted from cache updates in place when the refreshed copy lands (see
/// `CachePolicy.peopleGroupCounts`).
class CachedDataBuilder<T> extends StatefulWidget {
  const CachedDataBuilder({
    super.key,
    required this.cacheKey,
    required this.fetch,
    required this.builder,
    required this.loading,
    required this.error,
    this.fadeDuration,
  });

  /// Identifies the cached value; must be the key the [fetch] caches under.
  /// Changing it (a new day on the Pray screen, a new language) re-peeks and
  /// refetches.
  final String cacheKey;

  /// Must resolve through `getJsonCached`, which is what makes the peek and the
  /// background revalidation work. [forceRefresh] is passed on retry.
  final Future<T> Function({bool forceRefresh}) fetch;

  final Widget Function(BuildContext context, T data) builder;

  /// Built only while there is nothing cached to show.
  final WidgetBuilder loading;

  /// Built when the fetch failed and no cached value — not even an expired one
  /// — was available to fall back on.
  final Widget Function(BuildContext context, VoidCallback retry) error;

  /// When set, the skeleton fades into the data (or the error) over this long
  /// rather than being swapped for it in one frame. Data that was cached
  /// paints in the first frame as ever — there is no skeleton to fade from.
  final Duration? fadeDuration;

  @override
  State<CachedDataBuilder<T>> createState() => _CachedDataBuilderState<T>();
}

class _CachedDataBuilderState<T> extends State<CachedDataBuilder<T>> {
  T? _data;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(CachedDataBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cacheKey != widget.cacheKey) {
      removeCacheListener(oldWidget.cacheKey, _onRevalidated);
      _attach();
    }
  }

  @override
  void dispose() {
    removeCacheListener(widget.cacheKey, _onRevalidated);
    super.dispose();
  }

  void _attach() {
    addCacheListener(widget.cacheKey, _onRevalidated);
    // The synchronous peek: whatever it finds is on screen in this same frame,
    // so no skeleton is ever built for cached data.
    _data = peekCached<T>(widget.cacheKey);
    _error = null;
    _load(forceRefresh: false);
  }

  void _load({required bool forceRefresh}) {
    final key = widget.cacheKey;
    widget
        .fetch(forceRefresh: forceRefresh)
        .then((value) {
          // Guards against a late response for a key we've since moved off.
          if (!mounted || key != widget.cacheKey) return;
          setState(() {
            _data = value;
            _error = null;
          });
        })
        .catchError((Object error) {
          if (!mounted || key != widget.cacheKey) return;
          // `getJsonCached` already falls back to an expired cache entry, so
          // reaching here means there was nothing cached at all. Keeping any
          // value we do hold beats replacing it with an error.
          if (_data != null) return;
          setState(() => _error = error);
        });
  }

  void _onRevalidated(Object value) {
    if (!mounted) return;
    // Keys are type-stable, so this only ever fails if two callers share a key
    // with different payload types — in which case ignoring it is right.
    if (value is T) {
      final fresh = value as T;
      setState(() {
        _data = fresh;
        _error = null;
      });
    }
  }

  void _retry() {
    setState(() => _error = null);
    _load(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final Widget child;
    final String state;
    if (data != null) {
      child = widget.builder(context, data);
      state = 'data';
    } else if (_error != null) {
      child = widget.error(context, _retry);
      state = 'error';
    } else {
      child = widget.loading(context);
      state = 'loading';
    }
    final fade = widget.fadeDuration;
    if (fade == null) return child;
    return AnimatedSwitcher(
      duration: fade,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      child: KeyedSubtree(key: ValueKey(state), child: child),
    );
  }
}
