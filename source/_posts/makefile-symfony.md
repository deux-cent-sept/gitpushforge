---
title: Utiliser un Makefile dans Symfony
tags: Outils, Symfony, Makefile
excerpt: Le Makefile est un outil puissant utilisé dans le développement logiciel pour automatiser des tâches courantes. Bien que traditionnellement associé au système d'exploitation Unix et au projet GNU, il est largement utilisé dans divers environnements, y compris les projets Symfony. 
date: 2023-07-26 21:47:16
---
## Introduction

Le Makefile est un outil utilisé dans le développement logiciel pour automatiser des tâches courantes. Bien que traditionnellement associé au système d'exploitation Unix et au projet GNU, il est largement utilisé dans divers environnements, y compris les projets Symfony. 

Dans cet article, nous allons voir comment mettre en place un Makefile avec Symfony, comment le faire proprement et de manière facilitée grâce à l'autocomplétion des commandes.

> Le Makefile va nous permettre de centraliser en un même endroit toutes les commandes disponibles dans notre projet, mais aussi de créer des process simplifiés pour les développeurs qui rejoignent le projet. Il est également possible de l’utiliser pour automatiser des tâches de déploiement, de tests, de qualité de code, etc.
> 

## Sommaire

- [D’où vient le Makefile](#D’ou-vient-le-Makefile)
- [Comprendre les mots clés](#Comprendre-les-mots-cles)
- [Organiser son Makefile](#Organiser-son-Makefile)
- [Un Makefile d'exemple 🌟](#Un-Makefile-d’exemple)
- [Permettre l'autocomplétion](#Permettre-l’autocompletion)

## D’où vient le Makefile

### Lien avec GNU

Le Makefile tire son nom de l'utilitaire "make" qui est utilisé pour construire des programmes en lisant un fichier de description des dépendances appelé Makefile. Le projet GNU a popularisé l'utilisation du Makefile, le rendant essentiel pour la construction de logiciels.

Initialement, il était, et est probablement toujours, utilisé pour compiler des programmes à partir de leur code source, en automatisant le processus de compilation, de liaison et d'autres tâches de construction. Cependant, avec le temps, son utilisation s'est étendue pour automatiser diverses tâches dans le développement de logiciels.

> C’est de GNU que vient la grosse tête de Gnou que vous voyez probablement dans votre éditeur ou dans les résultats de recherche.
> 

### Exemple d’utilisation

Le Makefile utilise une syntaxe spécifique pour définir des règles, des cibles et des dépendances qui permettent de spécifier les étapes nécessaires pour créer des fichiers.

```makefile
TARGET: DEPENDANCES
<TAB>RULE
<TAB>RULE
<TAB>RULE
```

> Attention à bien respecter les tabulations et à ne pas utiliser d’espaces pour définir les règles car vous risqueriez de rencontrer cette erreur : *`Makefile:X: *** séparateur manquant. Arrêt.`*
Cependant, un espace doit être utilisé avant chaque dépendance
> 

**La cible** correspond souvent au nom du fichier que l’on souhaite générer (vendor, node_modules, etc..), mais nous verrons plus tard qu’on peut détourner cette fonction pour créer des cibles factices.

**Les dépendances** sont les fichiers qui vont être pris en compte par Make afin de déterminer si la cible doit etre recréée ou non. Si la date de modification des fichiers de dépendances est plus récente que la cible, celle-ci doit etre recréée.

**Les règles** sont les commandes à lancer pour construire correctement la cible

```makefile
brique.txt:
	touch brique.txt

mur.txt: brique.txt
	touch mur.txt
```

Je vais lancer plusieurs fois `make mur.txt` et voir ce qu’il se passe :

```bash
# La première fois : make mur.txt
touch brique.txt # La dépendance n'existe pas elle est donc créée selon sa règle de création, un simple touch
touch mur.txt # La cible est créée selon sa règle également, un touch aussi
# La deuxième fois: make mur.txt
make: « mur.txt » est à jour. # mur.txt existe et aucune de ses dépendances n'a évoluée. Il n'y a rien de nouveau
# J'écris un mot dans brique.txt -> `echo "coucou" >> brique.txt` . Je relance `make mur.txt`
touch mur.txt #brique.txt existe et n'a aucune dépendance à analyser. En revanche mur.txt a une dépendance plus récente que lui, on le recrée donc
```

C’est le moment de complexifier l’exemple, et d’ajouter des subtilités, j’ai ce makefile :

```makefile
composer.json:
	composer init

vendor: composer.json
	composer install

run.sh: vendor
	touch run.sh
```

Si je lance `make run.sh` , make va d’abord créer la cible composer.json, puis vendor, puis run.sh. 

> Notez qu’une cible peut etre un fichier, mais aussi un dossier complet. Attention cependant à supprimer le dossier avant de le regénérer s’il n’est pas correctement analysé par make. Ici il vaut mieux ajouter `rm -rf vendor` avant le composer install.
> 

```makefile
vendor: composer.json
	rm -rf vendor
	composer install
```


## Comprendre les mots clés

Familiarisons-nous d’abord avec quelques notions clés.

1. **DEFAULT_GOAL** : Il s'agit de la cible qui est exécutée par defaut lorsque vous appelez simplement `make` sans spécifier de cible explicite. Cela permet d'exécuter automatiquement une tâche privilégiée quand on ne sait pas trop quoi lancer. Il pourrait s’agir d’un `make install` qui créerait toutes les dépendances par exemple, backend, comme frontend. Mais nous allons voir qu’il peut être intéressant de plutot appeler une commande `help`.

2. **.PHONY** : (Fictive, Factice, Fausse) Permet de déclarer des cibles fictives. Les cibles déclarées en tant que phony sont considérées comme ne construisant pas de fichier spécifique. Cela permet plusieurs choses, d’abord d'éviter les conflits avec des fichiers ayant le même nom que les cibles. Par exemple vous ne pourrez pas lancer un `make build` que vous auriez déclaré s’il existe un fichier `build` à jour. Afin de se débarasser de ce lien on va ajouter cette nouvelle commande à la liste des commandes fictives. On peut toutes les lister en début de fichier ou les ajouter au cas par cas après chaque commande, c’est vous qui voyez
    
    ```makefile
    .PHONY: build install ci docker etc...
    ```
    
    ou alors
    
    ```makefile
    make build:
    	[...]
    .PHONY: build
    ```
    
    
    > ♻️ C'est dans l'usage premier du makefile, celui qui permet de créer des fichiers que cette vérification est pertinente. Mais comme nous n'allons pas nous appuyer sur cette mécanique, vous pouvez vous passer de tous ces .PHONY et ajouter simplement `MAKEFLAGS += --always-make` en début de fichier. Vos règles seront systématiquement jouées, même si la cible a le même nom qu'un fichier existant et à jour.

    
3. **Variables** : Vous pouvez déclarer des variables et les utiliser partout dans le fichier. La déclaration est simple `VARIABLE = valeur` puis `$(VARIABLE)` afin de l’utiliser
Par exemple : 
    
    ```makefile
    PHP = php
    SYMFONY = $(PHP) bin/console
    
    database:
    	$(SYMFONY) doctrine:database:create --if-not-exists
    ```
    
    Il existe également des variables générique, la plus intéressante pour nous étant `$@` qui représente la cible courante.
    
    ```makefile
    database:
    	@echo "J'éxécute la commande $@"
    	@$(SYMFONY) doctrine:database:create --if-not-exists

	# J'éxécute la commande database
    ```
    
    >☝ J’en profite pour introduire un autre outil qui est le `@` en début de commande. Par defaut, make affichera les commandes qui sont éxécutées, mais vous pouvez les dissimuler ainsi pour plus d’esthétisme. Et comme j’aime ce qui est esthétique, je vais le mettre absolument partout au profit d’une description de ce qui est lancé comme ici.
    
    - Les autres variables génériques
        
        
        | Symbole | Représente |
        | --- | --- |
        | $? | Les dépendances qui ont été modifiées |
        | $^ | Toutes les dépendances |
        | $+ | Toutes les dépendances sans les doublons |
        | $< | La première dépendance |
        | $@ | La cible courante |

4. **Fonctions** : Elles nous serviront très peu pour nos usages. Je vous laisse donc libre de les explorer mais je ne les détaillerai pas ici. Sachez seulement qu’on les utilise ainsi : `$(fonction argument1,argument2)` , qu’il en existe beaucoup mais qu’il est aussi possible d’en définir.
    - Une liste de fonctions qui peuvent être intéressantes
        
        https://www.gnu.org/software/make/manual/html_node/Functions.html
        

## Organiser son Makefile

Pour bien structurer notre Makefile, nous allons suivre cette organisation :

1. **Variables** : Nous définirons des variables pour stocker des informations telles que les noms des fichiers, les executables, les répertoires, les options de compilation, etc. Cela rendra le Makefile plus flexible et facile à faire évoluer.
2. **Liste des commandes** : Nous créerons une liste exhaustive des commandes présentes dans le fichier et il sera possible de l’afficher par le biais d’une commande.
3. **Sections** : Nous regrouperons les commandes connexes dans des sections logiques, ce qui rendra le Makefile plus organisé et facile à explorer.
4. **Documentation** : Nous ajouterons des commentaires et des explications détaillées à côté de chaque commande pour faciliter la compréhension et permettre une meilleure collaboration entre les membres de l'équipe.

## Un Makefile d'exemple

```makefile
.DEFAULT_GOAL = help
MAKEFLAGS += --always-make

# ============= Variables 🧰 =============
ARGUMENTS = $(filter-out $@,$(MAKECMDGOALS))

PROJECT = nom_du_projet
WEB_CONTAINER = web
DOCKER_USER_ID = www-data
SYMFONY = php bin/console
EXEC_WEB = docker-compose exec -u$(DOCKER_USER_ID):$(DOCKER_USER_ID) $(WEB_CONTAINER)
PHPUNIT = ./vendor/bin/phpunit
PHPSTAN = ./vendor/bin/phpstan
PHP_CS_FIXER = ./vendor/bin/php-cs-fixer

## ============= Obtenir des infos ❓ =============
help: ## Affiche la liste des commandes disponibles
	@grep -E '(^[a-zA-Z%0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

list-vars: ## Affiche la liste des variables du Makefile
	@grep -E '^[a-zA-Z_-]+ = .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " = "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## ============= Installer le projet 🏗️ =============
composer: ## Installe les dépendances PHP du projet
	@rm -rf vendor
	@$(EXEC_WEB) composer install

node_modules: ## Installe les dépendances NodeJS du projet
	@rm -rf node_modules
	@npm install

watch: ## Lance le watcher pour les assets du projet
	@npm run watch

build-front: ## Build les assets du projet
	@npm run build

update: ## Met à jour les dépendances PHP du projet
	@$(EXEC_WEB) composer update --with-all-dependencies

assets: ## Installe les assets du projet
	@$(EXEC_WEB) $(SYMFONY) assets:install public/

database: ## Crée la base de données et le schéma
	@$(EXEC_WEB) $(SYMFONY) doctrine:database:drop --force --if-exists
	@$(EXEC_WEB) $(SYMFONY) doctrine:database:create --if-not-exists
	@$(EXEC_WEB) $(SYMFONY) doctrine:schema:create

fixtures: ## Ajoute les fixtures
	@$(EXEC_WEB) $(SYMFONY) doctrine:fixtures:load --no-interaction

env: ## Crée le fichier .env.local à partir du .env
	@cp .env .env.local

install: composer database assets build-front cc warmup ## Installe l'environnement de base nécessaire au déploiement en production
install-dev: composer database fixtures assets build-front cc warmup ## Installe l'environnement de base nécessaire au développement

## ============= Utiliser Symfony 🎼 =============
symfony: ## Utilise les commandes Symfony du projet (ex: make symfony debug:router)
	@$(EXEC_WEB) $(SYMFONY) $(ARGUMENTS)

cc: ## Vide le cache
	@$(EXEC_WEB) $(SYMFONY) c:c

warmup: ## Préchauffe le cache
	@$(EXEC_WEB) $(SYMFONY) cache:warmup

## ============= Utiliser Docker 🐋 =============
start: ## Démarre tous les containers
	@docker compose up --detach

stop: ## Stop tous les containers
	@docker-compose stop

down: ## Supprime tous les containers
	@docker-compose down --remove-orphans

build: ## Rebuild les images docker
	@docker compose build

logs: ## Affiche les logs des containers
	@docker-compose logs -f

bash: ## Attache un shell au container web
	@docker-compose exec web bash

## ============= Qualité du code 👀 =============
test: ## Lance les tests PHPUnit avec un filtre et un testsuite optionnels
	@$(eval testsuite ?= all)
	@$(eval filter ?= '.')
	@echo "Test suite : $(testsuite)"
	@echo "Filtre : $(filter)"
	@echo ""
	@$(EXEC_WEB) $(PHPUNIT) --testsuite=$(testsuite) --filter=$(filter) --stop-on-failure

test-all: ## Lance tous les tests PHPUnit
	@$(EXEC_WEB) $(PHPUNIT) --stop-on-failure

fix: ## Lance php-cs-fixer
	@$(EXEC_WEB) $(PHP_CS_FIXER) fix --verbose

phpstan: ## Lance PHPStan
	@$(EXEC_WEB) $(PHPSTAN) analyse -c phpstan.neon --memory-limit=-1

ci: fix phpstan test-all ## Lance tous les tests pour l'intégration continue
```

Voici le fichier Makefile que j’utilise sur un de mes projets, il est assez court, mais organisé. Il est grandement inspiré de l’excellent Makefile que nous fournit Loïc Vernet sur son blog [Juste ici](https://www.strangebuzz.com/fr/snippets/le-makefile-parfait-pour-symfony)  

Bien sur, beaucoup de mes recettes dépendent de la façon dont est construit mon environnement, j’ai l’habitude d’utiliser php et composer, directement dans mon container, afin que tout le monde partage les mêmes versions.

De la même manière, l’utilisateur qui va executer les commandes n’as pas forcément besoin d’être précisé selon que vous utilisez un entrypoint ou pas.
Ce que je veux dire c’est que vous allez sûrement devoir adapter 2 ou 3 choses, mais voilà une bonne base.

Comme je l'ai expliqué plus haut, j'ai ajouté une commande `help` qui affiche la liste des commandes disponibles et c'est le DEFAULT_GOAL. Cela permettra aux développeurs de voir rapidement les commandes disponibles et de les utiliser sans avoir à consulter la documentation.

```bash
 ============= Obtenir des infos ❓ ============= 
help                           Affiche la liste des commandes disponibles
list-vars                      Affiche la liste des variables du Makefile
 ============= Installer le projet 🏗️ ============= 
composer                       Installe les dépendances PHP du projet
node_modules                   Installe les dépendances NodeJS du projet
watch                          Lance le watcher pour les assets du projet
build-front                    Build les assets du projet
update                         Met à jour les dépendances PHP du projet
assets                         Installe les assets du projet
database                       Crée la base de données et le schéma
fixtures                       Ajoute les fixtures
env                            Crée le fichier .env.local à partir du .env
install                        Installe l´environnement de base nécessaire au déploiement en production
install-dev                    Installe l´environnement de base nécessaire au développement
 ============= Utiliser Symfony 🎼 ============= 
symfony                        Utilise les commandes Symfony du projet (ex: make symfony debug:router)
cc                             Vide le cache
warmup                         Préchauffe le cache
 ============= Utiliser Docker 🐋 ============= 
start                          Démarre tous les containers
stop                           Stop tous les containers
down                           Supprime tous les containers
build                          Rebuild les images docker
logs                           Affiche les logs des containers
bash                           Attache un shell au container web
 ============= Qualité du code 👀 ============= 
test                           Lance les tests PHPUnit avec un filtre et un testsuite optionnels
test-all                       Lance tous les tests PHPUnit
fix                            Lance php-cs-fixer
phpstan                        Lance PHPStan
ci                             Lance tous les tests pour l´intégration continue
```

## Permettre l'autocomplétion

Pour rendre l'utilisation du Makefile encore plus agréable, nous pouvons ajouter la prise en charge de l'autocomplétion des commandes. Cela permettra aux développeurs d'obtenir des suggestions de commandes lorsqu'ils utilisent l'onglet de complétion dans leur terminal.

Pour permettre l'autocomplétion, nous pouvons utiliser le paquet "make" fourni avec la plupart des distributions Linux. Vous pouvez vérifier s'il est déjà installé sur votre système en exécutant la commande suivante :

```bash
make --version
```

Si le paquet n'est pas déjà installé, vous pouvez l'installer en utilisant le gestionnaire de paquets de votre système.

Une fois qu’il est installé, vous pouvez ajouter les directives suivantes à votre fichier ~/.zshrc ou ~/.bashrc pour activer l'autocomplétion :

```bash
source /usr/share/bash-completion/completions/make  # Chemin dépendant de votre système
```

Après avoir rafraichi votre terminal, vous pourrez bénéficier de l'autocomplétion en utilisant la touche `tab` . Et voilà !