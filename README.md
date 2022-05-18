# K8S Mock Generation
This project allows you to generate standardized mock endpoints.

This project is `Mono-Repo` since an external webservice is not supposed to change a lot.
This also helps generating new mocks based on the existing ones (and way easyer to run locally).

The mocking mechanism is based on 2 powerfull tools :

* [MockServer] for the mocking part,
* [Kustomize] for the kubernetes specifications.
