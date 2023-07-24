# Blog HEXO 📝

Ce fichier README contient des informations utiles pour la gestion et le déploiement du blog.

## Table des matières 🔗

- [Installation](#installation)
- [Créer un article](#créer-un-article)
- [Déploiement sur GitHub](#déploiement-sur-github)
- [Roadmap des features à venir](#roadmap-des-features-à-venir)

---

## Installation 🏗️
Vous devez posséder la cli Hexo pour pouvoir gérer le blog. Pour l'installer, exécutez la commande suivante :
```bash
npm install -g hexo-cli
```

Cloner le projet: 
```bash
git clone git@github.com:deux-cent-sept/git-push-forge.github.io.git
```

Installer les dépendances: 
```bash 
npm install
```

---

## Créer un article 📑

Pour créer un nouvel article sur mon blog, suivez les étapes suivantes :

1. Exécutez la commande `hexo new post "Titre de l'article"`.
2. Un fichier markdown sera créé dans le répertoire `_posts`.
3. Ouvrez ce fichier et commencez à rédiger votre article en utilisant la syntaxe Markdown.

---

## Déploiement sur GitHub 🚀

Le blog déployé sur GitHub Pages. Voici comment déployer les modifications :

La cible du déploiement est spécifié dans `_config.yml` de cette manière
```yml
deploy:
  type: 'git'
  repo: 'git@github.com:deux-cent-sept/git-push-forge.github.io.git'
  branch: gh-pages
```
>En effet, c'est la branche `gh-pages` qui héberge les fichiers statiques qui servent à deployer le blog, cette branche est protégée et ne doit pas être modifiée manuellement.

Exécutez la commande `hexo generate` afin de générer les fichiers statiques du blog, puis `hexo deploy` pour publier ces fichiers sur la branche `gh-pages`.

>Un makefile a été créé et vous pouvez tout simplement lancer la commande `make deploy` qui lancera elle même ces deux commandes.

---

## Roadmap des features à venir ✨

>Penser aux plug-ins hexo pour les fonctionnalités existantes.

- [ ]  Configurer le blog pour ne pas travailler sur main, et pour deployer quand on merge une PR dans main.
- [ ]  Choix d'un thème
- [x]  Mise en place d'un flux RSS.
- [ ]  Intégration des commentaires utilisateurs.
- [ ]  Ajout d'un système de recherche.