# Prayer Thank-You Modal — Rolling Verses

## What this is

After tapping **Amen** the modal shows the existing **title** and a **verse**. The encouraging
message is gone. The app rotates through the verse set below, advancing one verse per Amen and
wrapping at the end, so a returning user gets a new verse each session.

Each locale shows the verse in **that locale's own Bible translation** — not a translation of
the English. The translations are the ones the prayer platform already uses, from
`doxa-campaigns-server/config/languages.ts`.

| Locale | Translation | Bolls ID | Copyright |
|---|---|---|---|
| en | New King James Version | `NKJV` | notice required |
| es | Nueva Versión Internacional | `NVI` | notice required |
| pt | Nova Almeida Atualizada | `NAA` | notice required |
| fr | Louis Segond 1910 | `FRLSG` | public domain |
| ru | Синодальный перевод | `SYNOD` | public domain |
| ar | الكتاب المقدس - سميث وفاندايك | `SVD` | public domain |

## How to change the set

Edit `REFERENCES` in `tool/fetch_thank_you_verses.py`,
If needed add book names for english and arabic to `EN_BOOKS` and `AR_BOOKS` in `tool/fetch_thank_you_verses.py`
then run:

```
python3 tool/fetch_thank_you_verses.py
```

That rewrites `assets/thank_you_verses.json`, which is what the app ships. Do not edit the
JSON by hand, and **never send it through DeepL** — the text must be reproduced verbatim.

---

## The verses

Reference headings use English numbering. Where a translation numbers a passage differently,
the reference shown to that reader is the one printed beside their language — the number they
need to find it in their own Bible.

### 1. 1 Thessalonians 5:16-18

- **English · NKJV · 1 Thessalonians 5:16-18**
  Rejoice always, pray without ceasing, in everything give thanks; for this is the will of God in Christ Jesus for you.
- **Spanish · NVI · 1 Tesalonicenses 5:16-18**
  Estén siempre alegres, oren sin cesar, den gracias a Dios en toda situación, porque esta es su voluntad para ustedes en Cristo Jesús.
- **Portuguese · NAA · 1 Tessalonicenses 5:16-18**
  Estejam sempre alegres. Orem sem cessar. Em tudo, deem graças, porque esta é a vontade de Deus para vocês em Cristo Jesus.
- **French · LSG · 1 Thessaloniciens 5, 16-18**  ⟵ renumbered
  Soyez toujours joyeux. Priez sans cesse. Rendez grâces en toutes choses, car c’est à votre égard la volonté de Dieu en Jésus-Christ.
- **Russian · SYNOD · 1 Фессалоникийцам 5:16–18**  ⟵ renumbered
  Всегда радуйтесь. Непрестанно молитесь. За все благодарите: ибо такова о вас воля Божия во Христе Иисусе.
- **Arabic · SVD · 1 تسالونيكي 5:16-18**
  افْرَحُوا كُلَّ حِينٍ. صَلُّوا بِلاَ انْقِطَاعٍ. اشْكُرُوا فِي كُلِّ شَيْءٍ، لأَنَّ هذِهِ هِيَ مَشِيئَةُ اللهِ فِي الْمَسِيحِ يَسُوعَ مِنْ جِهَتِكُمْ.

### 2. Psalm 141:2

- **English · NKJV · Psalm 141:2**
  Let my prayer be set before You as incense, The lifting up of my hands as the evening sacrifice.
- **Spanish · NVI · Salmo 141:2**
  Que suba a tu presencia mi plegaria como una ofrenda de incienso; que hacia ti se eleven mis manos como un sacrificio vespertino.
- **Portuguese · NAA · Salmos 141:2**
  Suba à tua presença a minha oração como incenso, e seja o erguer de minhas mãos como oferenda vespertina.
- **French · LSG · Psaumes 141, 2**  ⟵ renumbered
  Que ma prière soit devant ta face comme l’encens, Et l’élévation de mes mains comme l’offrande du soir!
- **Russian · SYNOD · Псалтирь 140:2**  ⟵ renumbered
  Да направится молитва моя, как фимиам, пред лице Твое, воздеяние рук моих - как жертва вечерняя.
- **Arabic · SVD · مزمور 141:2**
  لِتَسْتَقِمْ صَلاَتِي كَالْبَخُورِ قُدَّامَكَ. لِيَكُنْ رَفْعُ يَدَيَّ كَذَبِيحَةٍ مَسَائِيَّةٍ.

### 3. Psalm 116:1-2

- **English · NKJV · Psalm 116:1-2**
  I love the LORD, because He has heard My voice and my supplications. Because He has inclined His ear to me, Therefore I will call upon Him as long as I live.
- **Spanish · NVI · Salmo 116:1-2**
  Yo amo al SEÑOR porque él escucha mi voz suplicante. Por cuanto él inclina a mí su oído, lo invocaré toda mi vida.
- **Portuguese · NAA · Salmos 116:1-2**
  Amo o SENHOR, porque ele ouve a minha voz e as minhas súplicas. Porque inclinou para mim os seus ouvidos, eu o invocarei por toda a minha vida.
- **French · LSG · Psaumes 116, 1-2**  ⟵ renumbered
  J’aime l’Éternel, car il entend Ma voix, mes supplications; Car il a penché son oreille vers moi; Et je l’invoquerai toute ma vie.
- **Russian · SYNOD · Псалтирь 114:1–2**  ⟵ renumbered
  Я радуюсь, что Господь услышал голос мой, моление мое; приклонил ко мне ухо Свое, и потому буду призывать Его во все дни мои.
- **Arabic · SVD · مزمور 116:1-2**
  أَحْبَبْتُ لأَنَّ الرَّبَّ يَسْمَعُ صَوْتِي، تَضَرُّعَاتِي. لأَنَّهُ أَمَالَ أُذْنَهُ إِلَيَّ فَأَدْعُوهُ مُدَّةَ حَيَاتِي.

### 4. Jeremiah 29:12

- **English · NKJV · Jeremiah 29:12**
  Then you will call upon Me and go and pray to Me, and I will listen to you.
- **Spanish · NVI · Jeremías 29:12**
  Entonces ustedes me invocarán, y vendrán a suplicarme, y yo los escucharé.
- **Portuguese · NAA · Jeremias 29:12**
  Então vocês me invocarão, se aproximarão de mim em oração, e eu os ouvirei.
- **French · LSG · Jérémie 29, 12**  ⟵ renumbered
  Vous m’invoquerez, et vous partirez; vous me prierez, et je vous exaucerai.
- **Russian · SYNOD · Иеремия 29:12**
  И воззовете ко Мне, и пойдете и помолитесь Мне, и Я услышу вас;
- **Arabic · SVD · إرميا 29:12**
  فَتَدْعُونَنِي وَتَذْهَبُونَ وَتُصَلُّونَ إِلَيَّ فَأَسْمَعُ لَكُمْ.

### 5. Psalm 145:18

- **English · NKJV · Psalm 145:18**
  The LORD is near to all who call upon Him, To all who call upon Him in truth.
- **Spanish · NVI · Salmo 145:18**
  El SEÑOR está cerca de quienes lo invocan, de quienes lo invocan en verdad.
- **Portuguese · NAA · Salmos 145:18**
  Perto está o SENHOR de todos os que o invocam, de todos os que o invocam em verdade.
- **French · LSG · Psaumes 145, 18**  ⟵ renumbered
  L’Éternel est près de tous ceux qui l’invoquent, De tous ceux qui l’invoquent avec sincérité;
- **Russian · SYNOD · Псалтирь 144:18**  ⟵ renumbered
  Близок Господь ко всем призывающим Его, ко всем призывающим Его в истине.
- **Arabic · SVD · مزمور 145:18**
  الرَّبُّ قَرِيبٌ لِكُلِّ الَّذِينَ يَدْعُونَهُ، الَّذِينَ يَدْعُونَهُ بِالْحَقِّ.

### 6. 1 Peter 3:12

- **English · NKJV · 1 Peter 3:12**
  For the eyes of the LORD are on the righteous, And His ears are open to their prayers; But the face of the LORD is against those who do evil.”
- **Spanish · NVI · 1 Pedro 3:12**
  Porque los ojos del Señor están sobre los justos, y sus oídos, atentos a sus oraciones; pero el rostro del Señor está contra los que hacen el mal».
- **Portuguese · NAA · 1 Pedro 3:12**
  Porque os olhos do Senhor repousam sobre os justos, e os seus ouvidos estão abertos às suas súplicas, mas o rosto do Senhor está contra aqueles que praticam o mal.”
- **French · LSG · 1 Pierre 3, 12**  ⟵ renumbered
  Car les yeux du Seigneur sont sur les justes Et ses oreilles sont attentives à leur prière, Mais la face du Seigneur est contre ceux qui font le mal.
- **Russian · SYNOD · 1 Петра 3:12**
  потому что очи Господа обращены к праведным и уши Его к молитве их, но лице Господне против делающих зло, (чтобы истребить их с земли).
- **Arabic · SVD · 1 بطرس 3:12**
  لأَنَّ عَيْنَيِ الرَّبِّ عَلَى الأَبْرَارِ، وَأُذْنَيْهِ إِلَى طَلِبَتِهِمْ، وَلكِنَّ وَجْهَ الرَّبِّ ضِدُّ فَاعِلِي الشَّرِّ».

### 7. Isaiah 65:24

- **English · NKJV · Isaiah 65:24**
  “It shall come to pass That before they call, I will answer; And while they are still speaking, I will hear.
- **Spanish · NVI · Isaías 65:24**
  Antes que me llamen, yo les responderé; todavía estarán hablando cuando ya los habré escuchado.
- **Portuguese · NAA · Isaías 65:24**
  Antes mesmo que clamem, eu responderei; estando eles ainda falando, eu os ouvirei.
- **French · LSG · Ésaïe 65, 24**  ⟵ renumbered
  Avant qu’ils m’invoquent, je répondrai; Avant qu’ils aient cessé de parler, j’exaucerai.
- **Russian · SYNOD · Исаия 65:24**
  И будет, прежде нежели они воззовут, Я отвечу; они еще будут говорить, и Я уже услышу.
- **Arabic · SVD · إشعياء 65:24**
  وَيَكُونُ أَنِّي قَبْلَمَا يَدْعُونَ أَنَا أُجِيبُ، وَفِيمَا هُمْ يَتَكَلَّمُونَ بَعْدُ أَنَا أَسْمَعُ.

### 8. Matthew 6:6

- **English · NKJV · Matthew 6:6**
  But you, when you pray, go into your room, and when you have shut your door, pray to your Father who is in the secret place; and your Father who sees in secret will reward you openly.
- **Spanish · NVI · Mateo 6:6**
  Pero tú, cuando te pongas a orar, entra en tu cuarto, cierra la puerta y ora a tu Padre, que está en lo secreto. Así tu Padre, que ve lo que se hace en secreto, te recompensará.
- **Portuguese · NAA · Mateus 6:6**
  Mas, ao orar, entre no seu quarto e, fechada a porta, ore ao seu Pai, que está em secreto. E o seu Pai, que vê em secreto, lhe dará a recompensa.
- **French · LSG · Matthieu 6, 6**  ⟵ renumbered
  Mais quand tu pries, entre dans ta chambre, ferme ta porte, et prie ton Père qui est là dans le lieu secret; et ton Père, qui voit dans le secret, te le rendra.
- **Russian · SYNOD · Матфея 6:6**
  Ты же, когда молишься, войди в комнату твою и, затворив дверь твою, помолись Отцу твоему, Который втайне; и Отец твой, видящий тайное, воздаст тебе явно.
- **Arabic · SVD · متى 6:6**
  وَأَمَّا أَنْتَ فَمَتَى صَلَّيْتَ فَادْخُلْ إِلَى مِخْدَعِكَ وَأَغْلِقْ بَابَكَ، وَصَلِّ إِلَى أَبِيكَ الَّذِي فِي الْخَفَاءِ. فَأَبُوكَ الَّذِي يَرَى فِي الْخَفَاءِ يُجَازِيكَ عَلاَنِيَةً.

### 9. Psalm 86:9

- **English · NKJV · Psalm 86:9**
  All nations whom You have made Shall come and worship before You, O Lord, And shall glorify Your name.
- **Spanish · NVI · Salmo 86:9**
  Todas las naciones que has creado vendrán, Señor, y ante ti se postrarán y glorificarán tu nombre.
- **Portuguese · NAA · Salmos 86:9**
  Todas as nações que fizeste virão, se prostrarão diante de ti, Senhor, e glorificarão o teu nome.
- **French · LSG · Psaumes 86, 9**  ⟵ renumbered
  Toutes les nations que tu as faites viendront Se prosterner devant ta face, Seigneur, Et rendre gloire à ton nom.
- **Russian · SYNOD · Псалтирь 85:9**  ⟵ renumbered
  Все народы, Тобою сотворенные, приидут и поклонятся пред Тобою, Господи, и прославят имя Твое,
- **Arabic · SVD · مزمور 86:9**
  كُلُّ الأُمَمِ الَّذِينَ صَنَعْتَهُمْ يَأْتُونَ وَيَسْجُدُونَ أَمَامَكَ يَا رَبُّ، وَيُمَجِّدُونَ اسْمَكَ.

### 10. Psalm 2:8

- **English · NKJV · Psalm 2:8**
  Ask of Me, and I will give You The nations for Your inheritance, And the ends of the earth for Your possession.
- **Spanish · NVI · Salmo 2:8**
  Pídeme, y como herencia te entregaré las naciones; ¡tuyos serán los confines de la tierra!
- **Portuguese · NAA · Salmos 2:8**
  Peça, e eu lhe darei as nações por herança e as extremidades da terra por sua possessão.
- **French · LSG · Psaumes 2, 8**  ⟵ renumbered
  Demande-moi et je te donnerai les nations pour héritage, Les extrémités de la terre pour possession;
- **Russian · SYNOD · Псалтирь 2:8**
  проси у Меня, и дам народы в наследие Тебе и пределы земли во владение Тебе;
- **Arabic · SVD · مزمور 2:8**
  اسْأَلْنِي فَأُعْطِيَكَ الأُمَمَ مِيرَاثًا لَكَ، وَأَقَاصِيَ الأَرْضِ مُلْكًا لَكَ.

### 11. Revelation 7:9

- **English · NKJV · Revelation 7:9**
  After these things I looked, and behold, a great multitude which no one could number, of all nations, tribes, peoples, and tongues, standing before the throne and before the Lamb, clothed with white robes, with palm branches in their hands,
- **Spanish · NVI · Apocalipsis 7:9**
  Después de esto miré, y apareció una multitud tomada de todas las naciones, tribus, pueblos y lenguas; era tan grande que nadie podía contarla. Estaban de pie delante del trono y del Cordero, vestidos de túnicas blancas y con ramas de palma en la mano.
- **Portuguese · NAA · Apocalipse 7:9**
  Depois destas coisas, vi, e eis grande multidão que ninguém podia contar, de todas as nações, tribos, povos e línguas, em pé diante do trono e diante do Cordeiro, vestidos de vestes brancas, com ramos de palmeira nas mãos.
- **French · LSG · Apocalypse 7, 9**  ⟵ renumbered
  Après cela, je regardai, et voici, il y avait une grande foule, que personne ne pouvait compter, de toute nation, de toute tribu, de tout peuple, et de toute langue. Ils se tenaient devant le trône et devant l’agneau, revêtus de robes blanches, et des palmes dans leurs mains.
- **Russian · SYNOD · Откровение 7:9**
  После сего взглянул я, и вот, великое множество людей, которого никто не мог перечесть, из всех племен и колен, и народов и языков, стояло пред престолом и пред Агнцем в белых одеждах и с пальмовыми ветвями в руках своих.
- **Arabic · SVD · رؤيا 7:9**
  بَعْدَ هذَا نَظَرْتُ وَإِذَا جَمْعٌ كَثِيرٌ لَمْ يَسْتَطِعْ أَحَدٌ أَنْ يَعُدَّهُ، مِنْ كُلِّ الأُمَمِ وَالْقَبَائِلِ وَالشُّعُوبِ وَالأَلْسِنَةِ، وَاقِفُونَ أَمَامَ الْعَرْشِ وَأَمَامَ الْخَرُوفِ، مُتَسَرْبِلِينَ بِثِيَابٍ بِيضٍ وَفِي أَيْدِيهِمْ سَعَفُ النَّخْلِ

### 12. Matthew 9:38

- **English · NKJV · Matthew 9:38**
  Therefore pray the Lord of the harvest to send out laborers into His harvest.”
- **Spanish · NVI · Mateo 9:38**
  Pídanle, por tanto, al Señor de la cosecha que envíe obreros a su campo».
- **Portuguese · NAA · Mateus 9:38**
  Por isso, peçam ao Senhor da seara que mande trabalhadores para a sua seara.
- **French · LSG · Matthieu 9, 38**  ⟵ renumbered
  Priez donc le maître de la moisson d’envoyer des ouvriers dans sa moisson.
- **Russian · SYNOD · Матфея 9:38**
  итак молите Господина жатвы, чтобы выслал делателей на жатву Свою.
- **Arabic · SVD · متى 9:38**
  فَاطْلُبُوا مِنْ رَبِّ الْحَصَادِ أَنْ يُرْسِلَ فَعَلَةً إِلَى حَصَادِهِ».

### 13. Psalm 67:1-2

- **English · NKJV · Psalm 67:1-2**
  God be merciful to us and bless us, And cause His face to shine upon us, That Your way may be known on earth, Your salvation among all nations.
- **Spanish · NVI · Salmo 67:1-2**
  Al director musical. Acompáñese con instrumentos de cuerda. Salmo. Cántico. Dios nos tenga compasión y nos bendiga; Dios haga resplandecer su rostro sobre nosotros, para que se conozcan en la tierra sus caminos, y entre todas las naciones su salvación.
- **Portuguese · NAA · Salmos 67:1-2**
  Ao mestre de canto. Para instrumentos de cordas. Salmo. Cântico Seja Deus gracioso para conosco, e nos abençoe, e faça resplandecer sobre nós o seu rosto; para que se conheça na terra o teu caminho e, em todas as nações, a tua salvação.
- **French · LSG · Psaumes 67, 2-3**  ⟵ renumbered
  Que Dieu ait pitié de nous et qu’il nous bénisse, Qu’il fasse luire sur nous sa face, Afin que l’on connaisse sur la terre ta voie, Et parmi toutes les nations ton salut!
- **Russian · SYNOD · Псалтирь 66:2–3**  ⟵ renumbered
  Боже! будь милостив к нам и благослови нас, освети нас лицем Твоим, дабы познали на земле путь Твой, во всех народах спасение Твое.
- **Arabic · SVD · مزمور 67:1-2**
  لِيَتَحَنَّنِ اللهُ عَلَيْنَا وَلْيُبَارِكْنَا. لِيُنِرْ بِوَجْهِهِ عَلَيْنَا. لِكَيْ يُعْرَفَ فِي الأَرْضِ طَرِيقُكَ، وَفِي كُلِّ الأُمَمِ خَلاَصُكَ.

### 14. Habakkuk 2:14

- **English · NKJV · Habakkuk 2:14**
  For the earth will be filled With the knowledge of the glory of the LORD, As the waters cover the sea.
- **Spanish · NVI · Habacuc 2:14**
  Porque así como las aguas cubren los mares, así también se llenará la tierra del conocimiento de la gloria del SEÑOR.
- **Portuguese · NAA · Habacuque 2:14**
  Porque a terra se encherá do conhecimento da glória do SENHOR, como as águas cobrem o mar.
- **French · LSG · Habacuc 2, 14**  ⟵ renumbered
  Car la terre sera remplie de la connaissance de la gloire de l’Éternel, Comme le fond de la mer par les eaux qui le couvrent.
- **Russian · SYNOD · Аввакум 2:14**
  Ибо земля наполнится познанием славы Господа, как воды наполняют море.
- **Arabic · SVD · حبقوق 2:14**
  لأَنَّ الأَرْضَ تَمْتَلِئُ مِنْ مَعْرِفَةِ مَجْدِ الرَّبِّ كَمَا تُغَطِّي الْمِيَاهُ الْبَحْرَ.

### 15. Romans 10:14

- **English · NKJV · Romans 10:14**
  How then shall they call on Him in whom they have not believed? And how shall they believe in Him of whom they have not heard? And how shall they hear without a preacher?
- **Spanish · NVI · Romanos 10:14**
  Ahora bien, ¿cómo invocarán a aquel en quien no han creído? ¿Y cómo creerán en aquel de quien no han oído? ¿Y cómo oirán si no hay quien les predique?
- **Portuguese · NAA · Romanos 10:14**
  Como, porém, invocarão aquele em quem não creram? E como crerão naquele de quem nada ouviram? E como ouvirão, se não há quem pregue?
- **French · LSG · Romains 10, 14**  ⟵ renumbered
  Comment donc invoqueront-ils celui en qui ils n’ont pas cru? Et comment croiront-ils en celui dont ils n’ont pas entendu parler? Et comment en entendront-ils parler, s’il n’y a personne qui prêche?
- **Russian · SYNOD · Римлянам 10:14**
  Но как призывать Того, в Кого не уверовали? как веровать в Того, о Ком не слыхали? как слышать без проповедующего?
- **Arabic · SVD · رومية 10:14**
  فَكَيْفَ يَدْعُونَ بِمَنْ لَمْ يُؤْمِنُوا بِهِ؟ وَكَيْفَ يُؤْمِنُونَ بِمَنْ لَمْ يَسْمَعُوا بِهِ؟ وَكَيْفَ يَسْمَعُونَ بِلاَ كَارِزٍ؟

### 16. Colossians 4:3

- **English · NKJV · Colossians 4:3**
  meanwhile praying also for us, that God would open to us a door for the word, to speak the mystery of Christ, for which I am also in chains,
- **Spanish · NVI · Colosenses 4:3**
  y, al mismo tiempo, intercedan por nosotros a fin de que Dios nos abra las puertas para proclamar la palabra, el misterio de Cristo por el cual estoy preso.
- **Portuguese · NAA · Colossenses 4:3**
  Ao mesmo tempo, orem também por nós, para que Deus nos abra uma porta à palavra, a fim de falarmos do mistério de Cristo, pelo qual também estou algemado.
- **French · LSG · Colossiens 4, 3**  ⟵ renumbered
  Priez en même temps pour nous, afin que Dieu nous ouvre une porte pour la parole, en sorte que je puisse annoncer le mystère de Christ, pour lequel je suis dans les chaînes,
- **Russian · SYNOD · Колоссянам 4:3**
  Молитесь также и о нас, чтобы Бог отверз нам дверь для слова, возвещать тайну Христову, за которую я и в узах,
- **Arabic · SVD · كولوسي 4:3**
  مُصَلِّينَ فِي ذلِكَ لأَجْلِنَا نَحْنُ أَيْضًا، لِيَفْتَحَ الرَّبُّ لَنَا بَابًا لِلْكَلاَمِ، لِنَتَكَلَّمَ بِسِرِّ الْمَسِيحِ، الَّذِي مِنْ أَجْلِهِ أَنَا مُوثَقٌ أَيْضًا،

### 17. 1 Timothy 2:4

- **English · NKJV · 1 Timothy 2:4**
  who desires all men to be saved and to come to the knowledge of the truth.
- **Spanish · NVI · 1 Timoteo 2:4**
  pues él quiere que todos sean salvos y lleguen a conocer la verdad.
- **Portuguese · NAA · 1 Timóteo 2:4**
  que deseja que todos sejam salvos e cheguem ao pleno conhecimento da verdade.
- **French · LSG · 1 Timothée 2, 4**  ⟵ renumbered
  qui veut que tous les hommes soient sauvés et parviennent à la connaissance de la vérité.
- **Russian · SYNOD · 1 Тимофею 2:4**
  Который хочет, чтобы все люди спаслись и достигли познания истины.
- **Arabic · SVD · 1 تيموثاوس 2:4**
  الَّذِي يُرِيدُ أَنَّ جَمِيعَ النَّاسِ يَخْلُصُونَ، وَإِلَى مَعْرِفَةِ الْحَقِّ يُقْبِلُونَ.

### 18. 2 Peter 3:9

- **English · NKJV · 2 Peter 3:9**
  The Lord is not slack concerning His promise, as some count slackness, but is longsuffering toward us, not willing that any should perish but that all should come to repentance.
- **Spanish · NVI · 2 Pedro 3:9**
  El Señor no tarda en cumplir su promesa, según entienden algunos la tardanza. Más bien, él tiene paciencia con ustedes, porque no quiere que nadie perezca, sino que todos se arrepientan.
- **Portuguese · NAA · 2 Pedro 3:9**
  O Senhor não retarda a sua promessa, ainda que alguns a julguem demorada. Pelo contrário, ele é paciente com vocês, não querendo que ninguém pereça, mas que todos cheguem ao arrependimento.
- **French · LSG · 2 Pierre 3, 9**  ⟵ renumbered
  Le Seigneur ne tarde pas dans l’accomplissement de la promesse, comme quelques-uns le croient; mais il use de patience envers vous, ne voulant pas qu’aucun périsse, mais voulant que tous arrivent à la repentance.
- **Russian · SYNOD · 2 Петра 3:9**
  Не медлит Господь исполнением обетования, как некоторые почитают то медлением; но долготерпит нас, не желая, чтобы кто погиб, но чтобы все пришли к покаянию.
- **Arabic · SVD · 2 بطرس 3:9**
  Pلاَ يَتَبَاطَأُ الرَّبُّ عَنْ وَعْدِهِ كَمَا يَحْسِبُ قَوْمٌ التَّبَاطُؤَ، لكِنَّهُ يَتَأَنَّى عَلَيْنَا، وَهُوَ لاَ يَشَاءُ أَنْ يَهْلِكَ أُنَاسٌ، بَلْ أَنْ يُقْبِلَ الْجَمِيعُ إِلَى التَّوْبَةِ. P

### 19. Matthew 24:14

- **English · NKJV · Matthew 24:14**
  And this gospel of the kingdom will be preached in all the world as a witness to all the nations, and then the end will come.
- **Spanish · NVI · Mateo 24:14**
  Y este evangelio del reino se predicará en todo el mundo como testimonio a todas las naciones, y entonces vendrá el fin.
- **Portuguese · NAA · Mateus 24:14**
  E será pregado este evangelho do Reino por todo o mundo, para testemunho a todas as nações. Então virá o fim.
- **French · LSG · Matthieu 24, 14**  ⟵ renumbered
  Cette bonne nouvelle du royaume sera prêchée dans le monde entier, pour servir de témoignage à toutes les nations. Alors viendra la fin.
- **Russian · SYNOD · Матфея 24:14**
  И проповедано будет сие Евангелие Царствия по всей вселенной, во свидетельство всем народам; и тогда придет конец.
- **Arabic · SVD · متى 24:14**
  وَيُكْرَزُ بِبِشَارَةِ الْمَلَكُوتِ هذِهِ فِي كُلِّ الْمَسْكُونَةِ شَهَادَةً لِجَمِيعِ الأُمَمِ. ثُمَّ يَأْتِي الْمُنْتَهَى.

### 20. Matthew 6:10

- **English · NKJV · Matthew 6:10**
  Your kingdom come. Your will be done On earth as it is in heaven.
- **Spanish · NVI · Mateo 6:10**
  venga tu reino, hágase tu voluntad en la tierra como en el cielo.
- **Portuguese · NAA · Mateus 6:10**
  venha o teu Reino; seja feita a tua vontade, assim na terra como no céu;
- **French · LSG · Matthieu 6, 10**  ⟵ renumbered
  que ton règne vienne; que ta volonté soit faite sur la terre comme au ciel.
- **Russian · SYNOD · Матфея 6:10**
  да приидет Царствие Твое; да будет воля Твоя и на земле, как на небе;
- **Arabic · SVD · متى 6:10**
  لِيَأْتِ مَلَكُوتُكَ. لِتَكُنْ مَشِيئَتُكَ كَمَا فِي السَّمَاءِ كَذلِكَ عَلَى الأَرْضِ.

### 21. Isaiah 6:8

- **English · NKJV · Isaiah 6:8**
  Also I heard the voice of the Lord, saying: “Whom shall I send, And who will go for Us?” Then I said, “Here am I! Send me.”
- **Spanish · NVI · Isaías 6:8**
  Entonces oí la voz del Señor que decía: —¿A quién enviaré? ¿Quién irá por nosotros? Y respondí: —Aquí estoy. ¡Envíame a mí!
- **Portuguese · NAA · Isaías 6:8**
  Depois disto, ouvi a voz do Senhor, que dizia: — A quem enviarei, e quem há de ir por nós? Eu respondi: — Eis-me aqui, envia-me a mim.
- **French · LSG · Ésaïe 6, 8**  ⟵ renumbered
  J’entendis la voix du Seigneur, disant: Qui enverrai-je, et qui marchera pour nous? Je répondis: Me voici, envoie-moi.
- **Russian · SYNOD · Исаия 6:8**
  И услышал я голос Господа, говорящего: кого Мне послать? и кто пойдет для Нас? И я сказал: вот я, пошли меня.
- **Arabic · SVD · إشعياء 6:8**
  ثُمَّ سَمِعْتُ صَوْتَ السَّيِّدِ قَائِلاً: «مَنْ أُرْسِلُ؟ وَمَنْ يَذْهَبُ مِنْ أَجْلِنَا؟» فَقُلْتُ: «هأَنَذَا أَرْسِلْنِي».

### 22. Colossians 4:2

- **English · NKJV · Colossians 4:2**
  Continue earnestly in prayer, being vigilant in it with thanksgiving;
- **Spanish · NVI · Colosenses 4:2**
  Dedíquense a la oración: perseveren en ella con agradecimiento
- **Portuguese · NAA · Colossenses 4:2**
  Continuem a orar, vigiando em oração com ação de graças.
- **French · LSG · Colossiens 4, 2**  ⟵ renumbered
  Persévérez dans la prière, veillez-y avec actions de grâces.
- **Russian · SYNOD · Колоссянам 4:2**
  Будьте постоянны в молитве, бодрствуя в ней с благодарением.
- **Arabic · SVD · كولوسي 4:2**
  وَاظِبُوا عَلَى الصَّلاَةِ سَاهِرِينَ فِيهَا بِالشُّكْرِ،

### 23. Psalm 126:5

- **English · NKJV · Psalm 126:5**
  Those who sow in tears Shall reap in joy.
- **Spanish · NVI · Salmo 126:5**
  El que con lágrimas siembra, con regocijo cosecha.
- **Portuguese · NAA · Salmos 126:5**
  Os que com lágrimas semeiam com júbilo ceifarão.
- **French · LSG · Psaumes 126, 5**  ⟵ renumbered
  Ceux qui sèment avec larmes Moissonneront avec chants d’allégresse.
- **Russian · SYNOD · Псалтирь 125:5**  ⟵ renumbered
  Сеявшие со слезами будут пожинать с радостью.
- **Arabic · SVD · مزمور 126:5**
  الَّذِينَ يَزْرَعُونَ بِالدُّمُوعِ يَحْصُدُونَ بِالابْتِهَاجِ.

### 24. Ephesians 6:18

- **English · NKJV · Ephesians 6:18**
  praying always with all prayer and supplication in the Spirit, being watchful to this end with all perseverance and supplication for all the saints—
- **Spanish · NVI · Efesios 6:18**
  Oren en el Espíritu en todo momento, con peticiones y ruegos. Manténganse alerta y perseveren en oración por todos los santos.
- **Portuguese · NAA · Efésios 6:18**
  Orem em todo tempo no Espírito, com todo tipo de oração e súplica, e para isto vigiem com toda perseverança e súplica por todos os santos.
- **French · LSG · Éphésiens 6, 18**  ⟵ renumbered
  Faites en tout temps par l’Esprit toutes sortes de prières et de supplications. Veillez à cela avec une entière persévérance, et priez pour tous les saints.
- **Russian · SYNOD · Ефесянам 6:18**
  Всякою молитвою и прошением молитесь во всякое время духом, и старайтесь о сем самом со всяким постоянством и молением о всех святых
- **Arabic · SVD · أفسس 6:18**
  مُصَلِّينَ بِكُلِّ صَلاَةٍ وَطِلْبَةٍ كُلَّ وَقْتٍ فِي الرُّوحِ، وَسَاهِرِينَ لِهذَا بِعَيْنِهِ بِكُلِّ مُواظَبَةٍ وَطِلْبَةٍ، لأَجْلِ جَمِيعِ الْقِدِّيسِينَ،

### 25. 1 Timothy 2:1

- **English · NKJV · 1 Timothy 2:1**
  Therefore I exhort first of all that supplications, prayers, intercessions, and giving of thanks be made for all men,
- **Spanish · NVI · 1 Timoteo 2:1**
  Así que recomiendo, ante todo, que se hagan plegarias, oraciones, súplicas y acciones de gracias por todos,
- **Portuguese · NAA · 1 Timóteo 2:1**
  Antes de tudo, peço que se façam súplicas, orações, intercessões e ações de graças em favor de todas as pessoas.
- **French · LSG · 1 Timothée 2, 1**  ⟵ renumbered
  J’exhorte donc, avant toutes choses, à faire des prières, des supplications, des requêtes, des actions de grâces, pour tous les hommes,
- **Russian · SYNOD · 1 Тимофею 2:1**
  Итак прежде всего прошу совершать молитвы, прошения, моления, благодарения за всех человеков,
- **Arabic · SVD · 1 تيموثاوس 2:1**
  فَأَطْلُبُ أَوَّلَ كُلِّ شَيْءٍ، أَنْ تُقَامَ طَلِبَاتٌ وَصَلَوَاتٌ وَابْتِهَالاَتٌ وَتَشَكُّرَاتٌ لأَجْلِ جَمِيعِ النَّاسِ،

### 26. Romans 12:12

- **English · NKJV · Romans 12:12**
  rejoicing in hope, patient in tribulation, continuing steadfastly in prayer;
- **Spanish · NVI · Romanos 12:12**
  Alégrense en la esperanza, muestren paciencia en el sufrimiento, perseveren en la oración.
- **Portuguese · NAA · Romanos 12:12**
  Alegrem-se na esperança, sejam pacientes na tribulação e perseverem na oração.
- **French · LSG · Romains 12, 12**  ⟵ renumbered
  Réjouissez-vous en espérance. Soyez patients dans l’affliction. Persévérez dans la prière.
- **Russian · SYNOD · Римлянам 12:12**
  утешайтесь надеждою; в скорби будьте терпеливы, в молитве постоянны;
- **Arabic · SVD · رومية 12:12**
  فَرِحِينَ فِي الرَّجَاءِ، صَابِرِينَ فِي الضَِّيْقِ، مُواظِبِينَ عَلَى الصَّلاَةِ،

### 27. Luke 11:9

- **English · NKJV · Luke 11:9**
  “So I say to you, ask, and it will be given to you; seek, and you will find; knock, and it will be opened to you.
- **Spanish · NVI · Lucas 11:9**
  »Así que yo les digo: Pidan, y se les dará; busquen, y encontrarán; llamen, y se les abrirá la puerta.
- **Portuguese · NAA · Lucas 11:9**
  — Por isso, digo a vocês: Peçam e lhes será dado; busquem e acharão; batam, e a porta será aberta para vocês.
- **French · LSG · Luc 11, 9**  ⟵ renumbered
  Et moi, je vous dis: Demandez, et l’on vous donnera; cherchez, et vous trouverez; frappez, et l’on vous ouvrira.
- **Russian · SYNOD · Луки 11:9**
  И Я скажу вам: просите, и дано будет вам; ищите, и найдете; стучите, и отворят вам,
- **Arabic · SVD · لوقا 11:9**
  وَأَنَا أَقُولُ لَكُمُ: اسْأَلُوا تُعْطَوْا، اُطْلُبُوا تَجِدُوا، اِقْرَعُوا يُفْتَحْ لَكُمْ.

### 28. Zechariah 4:6

- **English · NKJV · Zechariah 4:6**
  So he answered and said to me: “This is the word of the LORD to Zerubbabel: ‘Not by might nor by power, but by My Spirit,’ Says the LORD of hosts.
- **Spanish · NVI · Zacarías 4:6**
  Así que el ángel me dijo: «Esta es la palabra del SEÑOR para Zorobabel: »“No será por la fuerza ni por ningún poder, sino por mi Espíritu —dice el SEÑOR Todopoderoso—.
- **Portuguese · NAA · Zacarias 4:6**
  Ele prosseguiu e me disse: — Esta é a palavra do SENHOR a Zorobabel: “Não por força nem por poder, mas pelo meu Espírito”, diz o SENHOR dos Exércitos.
- **French · LSG · Zacharie 4, 6**  ⟵ renumbered
  Alors il reprit et me dit: C’est ici la parole que l’Éternel adresse à Zorobabel: Ce n’est ni par la puissance ni par la force, mais c’est par mon esprit, dit l’Éternel des armées.
- **Russian · SYNOD · Захария 4:6**
  Тогда отвечал он и сказал мне так: это слово Господа к Зоровавелю, выражающее: не воинством и не силою, но Духом Моим, говорит Господь Саваоф.
- **Arabic · SVD · زكريا 4:6**
  فَأَجَابَ وَكَلَّمَنِي قَائِلاً: «هذِهِ كَلِمَةُ الرَّبِّ إِلَى زَرُبَّابِلَ قَائِلاً: لاَ بِالْقُدْرَةِ وَلاَ بِالْقُوَّةِ، بَلْ بِرُوحِي قَالَ رَبُّ الْجُنُودِ.

### 29. Isaiah 55:11

- **English · NKJV · Isaiah 55:11**
  So shall My word be that goes forth from My mouth; It shall not return to Me void, But it shall accomplish what I please, And it shall prosper in the thing for which I sent it.
- **Spanish · NVI · Isaías 55:11**
  así es también la palabra que sale de mi boca: No volverá a mí vacía, sino que hará lo que yo deseo y cumplirá con mis propósitos.
- **Portuguese · NAA · Isaías 55:11**
  assim será a palavra que sair da minha boca: não voltará para mim vazia, mas fará o que me apraz e prosperará naquilo para que a designei.”
- **French · LSG · Ésaïe 55, 11**  ⟵ renumbered
  Ainsi en est-il de ma parole, qui sort de ma bouche: Elle ne retourne point à moi sans effet, Sans avoir exécuté ma volonté Et accompli mes desseins.
- **Russian · SYNOD · Исаия 55:11**
  так и слово Мое, которое исходит из уст Моих, - оно не возвращается ко Мне тщетным, но исполняет то, что Мне угодно, и совершает то, для чего Я послал его.
- **Arabic · SVD · إشعياء 55:11**
  هكَذَا تَكُونُ كَلِمَتِي الَّتِي تَخْرُجُ مِنْ فَمِي. لاَ تَرْجعُ إِلَيَّ فَارِغَةً، بَلْ تَعْمَلُ مَا سُرِرْتُ بِهِ وَتَنْجَحُ فِي مَا أَرْسَلْتُهَا لَهُ.

### 30. Philippians 4:6

- **English · NKJV · Philippians 4:6**
  Be anxious for nothing, but in everything by prayer and supplication, with thanksgiving, let your requests be made known to God;
- **Spanish · NVI · Filipenses 4:6**
  No se inquieten por nada; más bien, en toda ocasión, con oración y ruego, presenten sus peticiones a Dios y denle gracias.
- **Portuguese · NAA · Filipenses 4:6**
  Não fiquem preocupados com coisa alguma, mas, em tudo, sejam conhecidos diante de Deus os pedidos de vocês, pela oração e pela súplica, com ações de graças.
- **French · LSG · Philippiens 4, 6**  ⟵ renumbered
  Ne vous inquiétez de rien; mais en toute chose faites connaître vos besoins à Dieu par des prières et des supplications, avec des actions de grâces.
- **Russian · SYNOD · Филиппийцам 4:6**
  Не заботьтесь ни о чем, но всегда в молитве и прошении с благодарением открывайте свои желания пред Богом,
- **Arabic · SVD · فيلبي 4:6**
  لاَ تَهْتَمُّوا بِشَيْءٍ، بَلْ فِي كُلِّ شَيْءٍ بِالصَّلاَةِ وَالدُّعَاءِ مَعَ الشُّكْرِ، لِتُعْلَمْ طِلْبَاتُكُمْ لَدَى اللهِ.

---

## What came up while building this

**1. These are Bolls.life IDs, not BibleGateway.** The IDs in `languages.ts` (`FRLSG`, `SYNOD`,
`SVD`, `S00`, `HIOV`) are Bolls.life identifiers, and `doxa-campaigns-server` already ships a
client for them. BibleGateway has no public API and does not serve this exact set under these
names, so the verses come from Bolls — the same source as the rest of the platform, which keeps
the app and the campaigns server showing identical text for the same reference.

**2. Russian and French renumber the Psalms, and this set is Psalm-heavy.** The Synodal text
follows the Greek psalter, so English Psalm 141 is Synodal Psalm 140 — asking `SYNOD` for
"Psalm 141" returns a different psalm. Six of the seven Psalms here need remapping for Russian,
and Psalm 67 needs a verse shift in French, where the superscription counts as verse 1. All
applied and checked against the English.

**3. A bug in the campaigns server's remap rules — worth fixing there separately.**
`server/utils/app/bolls-bible.ts` applies a blanket −1 chapter offset for `SYNOD` Psalms 10–146.
That is right across most of the range but wrong at the four places where the Hebrew and Greek
psalters merge or split:

| English | Correct Synodal | Blanket −1 gives |
|---|---|---|
| Psalm 10 | 9:22-39 | 9 — wrong verses |
| Psalm 115 | 113:9-26 | 114 — **wrong psalm** |
| Psalm 116:1-9 | 114 | 115 — **wrong psalm** |
| Psalm 147:12-20 | 147 | 146 — **wrong verses** |

This hit us directly: Psalm 116:1-2 resolved to Synodal 115:1-2, "Я веровал, и потому говорил",
which is Hebrew Psalm 116:**10**-11 — a different passage. `tool/fetch_thank_you_verses.py` has
the corrected table and a comment pointing at the server bug. Anything the campaigns server has
already published citing Psalms 10, 115, 116 or 147 in Russian may be showing the wrong text.

**4. Editorial apparatus had to be stripped.** Bolls returns psalm superscriptions inside
verse 1 ("To the Chief Musician. On stringed instruments…" arrived glued to Psalm 67:1), the
liturgical marker *Selah* / *Pause* / *سلاه* mid-verse, and footnote markers in `<sup>` — `[104]`
in the NVI, circled letters in the NAA. All are removed by the tool, and a test asserts none
creep back in.

**5. Book names cannot come from Bolls.** Its endpoint returns "The Book of PSALMS" for NKJV
and *English* names for the Arabic SVD, so English and Arabic book names are set explicitly in
the tool; Spanish, Portuguese, French and Russian come from Bolls with light tidying to match
the reference style already used in the `.arb` files.

---