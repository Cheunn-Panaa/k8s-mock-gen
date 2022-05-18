MOCK_NAME?=New-mock
K8S_ENV?=namespace
LOCAL_SHELL?=zsh

.PHONY: start clean create apply remove

start:
	@echo "## Démarrage du bouchon"
	@if [ ! -d ./overlay/$(MOCK_NAME) ]; then \
			echo "> Le bouchon $(MOCK_NAME) n'existe pas."; \
			exit 2; \
	 fi
	@docker-compose --file ./overlay/$(MOCK_NAME)/docker-compose.yml up

clean:
	@echo "## Nettoyage du bouchon local"
	@if [ ! -d ./overlay/$(MOCK_NAME) ]; then \
			echo "> Le bouchon $(MOCK_NAME) n'existe pas."; \
			exit 2; \
	 fi
	@docker-compose --file ./overlay/$(MOCK_NAME)/docker-compose.yml down -v

create:
	@echo "## Creation d'un nouveau Mock $(MOCK_NAME)"
	@if [ -d "overlay/$(MOCK_NAME)" ]; then \
		echo "> Le bouchon $(MOCK_NAME) existe déjà."; \
		exit 2; \
	 fi
	@echo "> Duplication du projet Sample vers $(MOCK_NAME)"
	@cp -R overlay/galec/ overlay/$(MOCK_NAME)/
	@echo "> Modification du fichier de configuration Kustomize"
	@sed -i.bck 's/sample/$(MOCK_NAME)/g' overlay/$(MOCK_NAME)/kustomization.yaml
	@sed -i.bck 's/sample/$(MOCK_NAME)/g' overlay/$(MOCK_NAME)/README.md
	@rm -rf overlay/$(MOCK_NAME)/*.bck
	@echo "> N'oubliez pas de mettre à jour la documentation."

apply:
	@echo "## Application du bouchon $(MOCK_NAME) sur $(K8S_ENV)"
	@if [[ ! "`kubectl get namespaces $(K8S_ENV) -o=jsonpath='{$$.metadata.name}'`" == "$(K8S_ENV)" ]]; then \
			echo "> $(K8S_ENV) n'est pas un espace de nom valide."; \
			exit 2; \
	 fi
	@if [ ! -d ./overlay/$(MOCK_NAME) ]; then \
			echo "> Le bouchon $(MOCK_NAME) n'existe pas."; \
			exit 2; \
	 fi
	@kubectl apply -n $(K8S_ENV) -k ./overlay/$(MOCK_NAME)

remove:
	@echo "## Suppression du bouchon $(MOCK_NAME) de $(K8S_ENV)"
	@if [[ ! "`kubectl get namespaces $(K8S_ENV) -o=jsonpath='{$$.metadata.name}'`" == "$(K8S_ENV)" ]]; then \
			echo "> $(K8S_ENV) n'est pas un espace de nom valide."; \
			exit 2; \
	 fi
	@kustomize build ./overlay/$(MOCK_NAME) | kubectl delete -n $(K8S_ENV) -f -
