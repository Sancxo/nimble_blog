%{
  title: "Elixir: la potion magique du développement web?",
  author: "Simon Tirant",
  tags: ~w(elixir phoenix web ruby rails erlang beam),
  lang: "fr",
  description: "Pourquoi Elixir est-il un bon choix de langage de programmation pour le développement web?",
  illustration: "/images/posts/pouf.gif",
  illustration_alt: "Magicien disparaissant dans un nuage de fumée"
}
---

👋 Adieu PHP, Ruby, Python, Java et JavaScript … Elixir est arrivé !  

![Logo du langage Elixir](/images/posts/elixir.png)

### Qu'est-ce que c'est que ce truc à la Merlin l'Enchanteur ⚗️ ?

Pour commencer, voyons l'historique d'Elixir : c'est un langage créé en **2011** par [José Valim](https://www.linkedin.com/in/josevalim/), un ancien membre de la core team du framework *[Ruby on Rails](https://rubyonrails.org/)* 💎, ce qui en fait un langage très récent ; d'autant plus qu'il n'a commencé à gagner en notoriété qu'à partir de 2015. Il est **purement fonctionnel** (*bye bye* l'orienté objet) et sa grande force réside dans son paradigme de **programmation concurrente**, basé sur les capacités multi-coeurs des processeurs modernes.  

### ☎️ Du téléphone fixe à What's App 📱

Mais cette dernière caractéristique ne sort pas de nulle part. En vrai, elle sort tout droit de la fin des années 1980 🥏💾🕹️🛹, puisqu'Elixir a été conçu sur les fondations d'un autre langage. En effet, en 1987 [Ericsson](https://www.linkedin.com/company/ericsson/) sort **Erlang**, un langage alors propriétaire - qui deviendra open source en 1998 - destiné à être utilisé dans des commutateurs téléphoniques, entre autres, et qui se base sur sa propre machine virtuelle : **BEAM** (*Bogdan/Björn's Erlang Abstract Machine*). C'est cette dernière qui est à l'origine du système multitâche d'Erlang, distribuant les opérations sur plusieurs cœurs, là où d'autres langages vont utiliser le *multithreading* (plusieurs processus exécutés sur un seul et même processeur). Quand on voit aujourd'hui que même un téléphone portable possède 6 à 8 cœurs 💕, on comprend facilement en quoi la vieille technologie d'Ericsson trouve un écho intéressant pour des applications actuelles.  

L'autre gros avantage d'Erlang, dont hérite Elixir, est la "**tolérance aux pannes**" (*fault tolerance*). Et pour mieux vous parler de ce concept, je vais directement citer l'ami Mark Wilbur, pédagogue sur Elixir et créateur du site [Alchemist.Camp](https://alchemist.camp/), au début de sa vidéo d'introduction à Elixir, traduite de l'anglais par mes soins :  


> Erlang a essentiellement été créé pour être tolérant aux pannes. Il a été conçu pour l'industrie des télécoms, donc le contraire d'une page web où un peu d'indisponibilité [..] n'est pas si grave. Évidemment vous n'en avez pas envie mais, vous savez, si je ne peux pas aller sur Twitter pendant 30 minutes environ, ce n'est pas la fin du monde. Alors que si je décroche mon téléphone et qu'il n'y a pas de tonalité, c'est plutôt un gros problème ; des gens pourraient littéralement mourir si cela arrivait, car les gens ne pourraient pas accéder au 911 [service des urgences américain, ndt], etc. Donc, la chose dans laquelle Erlang excelle, c'est de s'occuper de plein, plein de processus simultanés - comme des appels téléphoniques simultanés ou des messageries instantanées ou des choses comme ça. Et si une partie quelconque du système s'effondre, il est supervisé par d'autres parties de ce système qui vont le redémarrer et qui peuvent avoir des modèles d'organisation plutôt complexes. Et c'est en réalité un type de choses qui est difficile à faire avec la plupart des langages de programmation et la plupart des machines virtuelles. Alors ils le balancent au niveau du système et ont tout un paquet de containers Docker organisés par quelque chose comme Kubernetes. Avec Elixir, avec Erlang, c'est juste intégré avec OTP ["Open Telecom Platform", la plateforme logicielle/machine virtuelle fournie avec Erlang, ndt].  

> [Alchemist.Camp](https://alchemist.camp/episodes/welcome)  


Ce sont ces deux caractéristiques - la programmation concurrente et la tolérance aux pannes - issues du temps où le web n'était même pas encore inventé par Tim Berners-Lee (1989) 👨💻, qui permettent une **haute disponibilité de la donnée** et qui font d'Erlang, ainsi que d'Elixir, les technologies adoptées par les trois plus importantes applications de messagerie instantanée au monde : **[WhatsApp](https://www.linkedin.com/company/whatsapp./)** et **Facebook Messenger** utilisent Erlang, tandis que **[Discord](https://www.linkedin.com/company/discord/)** a fait le choix d'Elixir. Mais d'autres types d'applications, telles que les *chatbots* 🤖 ou les services de *streaming* 📺, ont tout à gagner de la programmation concurrente et de la tolérance aux pannes.

### Une syntaxe qui paie … Ruby sur l'ongle 💍

Si Erlang est aussi bien, alors pourquoi nous parler d'Elixir ❓ Quel est l'intérêt de créer un langage supplémentaire ❓

Alors, pour commencer, il y a des améliorations techniques à Erlang qui sont apportées par Elixir, notamment vis-à-vis du **polymorphisme** et de la **métaprogrammation**. Cependant je ne vais pas m'étendre sur celles-ci car je ne suis clairement pas compétent en la matière. Contentons-nous de rester à un niveau plus "vulgaire" de compréhension et allons plutôt aborder le point de la syntaxe d'Elixir. À la base, Erlang est un langage à la syntaxe rustique - pour ne pas dire rébarbative - avec beaucoup de code conventionnel répétitif ("*boilerplate code*"), ce qui le rend difficile à lire et parfois même à débuguer. Étant un ancien "*Rubyiste*", comme nous l'avons dit plus haut, José Valim avait à cœur d'apporter une syntaxe bien plus *sexy* 💃 et abordable que ce que proposait le langage d'Ericsson ; car c'est en partie ce qui fédère les développeurs autour d'une technologie en particulier, comme ça a été le cas avec Ruby. Il s'est donc directement inspiré du langage inventé en 1995 par le japonais Yukuhiro Matsumoto. **Sa syntaxe est une des raisons qui ont fait de Ruby le langage à succès qu'il est aujourd'hui**, adopté par bon nombre de startups innovantes dans les années 2000 - 2010. Les comparaisons entre du Ruby et de l'Elixir sont d'ailleurs frappantes de similitude ❗ Exemple avec un basique "*Hello World*" :

Ruby :

```
puts 'Hello World!'
```

Elixir :

```elixir
IO.puts "Hello World!"
```

C'est un comble quand on sait que dans Ruby tout est objet, alors qu'Elixir est purement fonctionnel ❗ Ce dernier point est d'ailleurs, à mon sens, une autre caractéristique - encore une fois héritée d'Erlang - à ajouter à la liste des avantages d'Elixir. En effet, qui dit programmation fonctionnelle dit **absence d'effets de bord**, et dit donc meilleur suivi et meilleure compréhension de la donnée ... pour l'homme comme pour la machine ❗ Ce qui résulte en un code **plus maintenable** et **plus réutilisable** ♻️.

Pour l'anecdote, c'est justement pour ces raisons que la célèbre librairie front-end **React** est en train de doucement migrer d'un système de composants écrits sous la forme de classes vers des composants fonctionnels - même si elle ne va pas les abandonner avant longtemps. À ce sujet, vous pouvez lire la fin de la documentation officielle de React concernant l'introduction des hooks : [Les raisons de l'adoption des hooks](https://fr.legacy.reactjs.org/docs/hooks-intro.html#motivation).

> "Les classes sont déroutantes pour les gens comme pour les machines." 

> [Documentation de React](https://fr.legacy.reactjs.org/docs/hooks-intro.html#classes-confuse-both-people-and-machines) 

La deuxième raison au succès de Ruby est son *framework* Ruby on Rails qui a permis à de nombreuses équipes réduites de développeurs de gagner en productivité dans l'écriture et l'organisation du code, ainsi que de monter leurs projets plus rapidement ; Elixir a lui aussi son équivalent à Rails : un beau framework web orienté MVC nommé **Phoenix** 🦅🔥 ; disposant de fonctionnalités, convoitées par de nombreux développeurs, augmentant la productivité et réduisant les temps de développement : telles que le ***scaffolding*** (littéralement "échafaudage") qui permet de générer automatiquement du code - incluant la création de la table en base de données, du gabarit ("*template*") HTML et des contrôleurs - à partir d'une simple ligne de commande dans le terminal. Ceci permet donc de créer une page pleinement dynamique en 5 secondes à peine ❗ Mais c'est à peu près là que s'arrête la comparaison avec les deux technologies, car les performances ne sont pas du tout les mêmes.

### Qui c'est qu'a la plus grosse ? 🏎️

Voyez ci dessous un tableau comparatif, issu encore une fois de la vidéo d'introduction du site [Alchemist.Camp](https://alchemist.camp/episodes/welcome):

![Tableau comparatif des langages/frameworks PHP, Java/Golang, Rails, Node, Elixir/Phoenix](/images/posts/language_table.png)

Selon Mark Wilbur, le créateur du site en question, Ruby est très bien pour monter une application rapidement ; notamment car son *framework* augmente beaucoup la productivité des développeurs. Il va donc plutôt s'adresser à des *startups* 🦄 ayant une petite équipe, ou encore à des développeurs travaillant seuls ; mais la croissance du projet devra forcément amener à faire des choix technologiques afin d'optimiser l'application, par exemple migrer vers Node. C'est d'ailleurs la principale critique qu'on rencontre à propos de Ruby : son manque de capacité à monter en charge (*scalability*). Les grosses performances vont plutôt se trouver du côté d'un langage robuste tel que Java, qui présente une plus grande rapidité d'exécution, utilise le *multi-threading* et facilite les tests, mais qui va plutôt s'adresser à de grosses compagnies 🏭 ayant de gros projets ; des usines à code dotées d'équipes de développeurs conséquentes et hiérarchisées, ainsi que des budgets plus importants permettant des *deadlines* plus longues.

Le combo Elixir/Phoenix va donc réunir les qualités de ces deux mondes : en affichant une bonne productivité - à l'instar d'un Ruby on Rails - couplé à d'assez bonnes performances, en facilitant lui aussi les tests et en permettant un meilleur suivi de la donnée (programmation fonctionnelle) ; et bien sûr en ajoutant sa touche Erlang : la programmation concurrente et la tolérance aux pannes ❗

### Sources:

- [Site officiel d'Elixir](https://elixir-lang.org/)
- [Wikipedia: Elixir](https://fr.wikipedia.org/wiki/Elixir_(langage))
- [Alchemist.camp: vidéo d'introduction à Elixir](https://alchemist.camp/episodes/welcome)
- [Wikipedia: Erlang](https://fr.wikipedia.org/wiki/Erlang_(langage))
- [Wikipedia: BEAM](https://fr.wikipedia.org/wiki/BEAM_(machine_virtuelle))
- [Wikipedia: Ruby](https://fr.wikipedia.org/wiki/Ruby)
- [Wikipedia: La programmation fonctionnelle](https://fr.wikipedia.org/wiki/Programmation_fonctionnelle)
- [Wikipedia: La programmation orientée objet](https://fr.wikipedia.org/wiki/Programmation_orient%C3%A9e_objet)
- [Wikipedia: Les effets de bord](https://fr.wikipedia.org/wiki/Effet_de_bord_(informatique))
- [React : documentation sur les hooks](https://fr.legacy.reactjs.org/docs/hooks-intro.html#motivation)

PS : Merci à [Olivier Deprez](https://www.linkedin.com/in/olivier-deprez-368b9b5/) de [7 Lieues Technologies](https://www.linkedin.com/company/7lieues-ia/) pour sa relecture et ses précieux conseils.
