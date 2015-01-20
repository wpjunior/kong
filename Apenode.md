#Overview

Welcome to the Apenode official documentation, that will help you setting up the Apenode, configuring it and operating it. We reccomend reading every section of this document to have a full understanding of the project.

If you have more specific questions about the Apenode, please join our chat at #apenode and the project maintainers will be happy to answer to your questions.

The Apenode is trusted by more than 100,000 developers, processing billions of requests for more than 10,000 public and private APIs around the world.

#What is the Apenode?

The Apenode is an open-source enterprise API Layer (also called *API Gateway* or *API Middleware*) that sits in front of any RESTful API and provides additional functionalities like authentication, analytics, monitoring, rate limiting and billing without changing the source code of the API itself. It is a foundamental technology that any API provider should leverage to deliver better APIs without reinventing the wheel.

This means that every request being made to the API will hit the Apenode first, and then it will be proxied to the final API with an average processing latency that is  lower than **8ms** per request. Because the Apenode can be easily scaled up and down there is no limit to the amount of requests it can serve, up to billions of HTTP requests.

[[IMAGE OF ARCHITECTURE, SHOWING CLIENT, APENODE AND API]]

The Apenode has been built following three foundamental principles:

* **Scalable**: it's easy to scale horizontally just by adding more machines. It can virtually handle any load.
* **Customizable**: it can be expanded by adding new features, and it's configurable by consuming an open internal API.
* **Runs on any infrastructure**: It can run in any cloud or on-premise environment, in a single or multi-datacenter setup, for any kind of API: public, private and partner APIs.

#Plugins

All the functionalities provided by the Apenode, like authentication, rate-limiting, billing, are implemented as **plugins**. Thus, there is an authentication plugin, a rate-limiting plugin, and a billing plugin among the others. You can decide which plugin to install, and you can customize the Apenode by creating new plugins.

In a way the Apenode can be considered as a container that executes plugins that provide additional functionalities to the underlying API.

By having plugins, the Apenode can be extended to fit any custom need or integration challenge. For example, if you need to integrate the API user authentication with a third-party enterprise security system, that would be implemented in a dedicated plugin that will run on every API request.

A plugin can hook into the life-cycle of both requests and responses, with the additional possibility of changing their content, thus allowing great customization. For example, a SOAP to REST converter plugin is totally possible with the Apenode.

#How does it work?

The Apenode is made of two different components, that are easy to set up and to scale independently:

* The **API Plugin Server**, based on a modified version of the widely adopted **nginx** server, that processes the API requests.
* An underlying **Datastore** for storing operational data, **Apache Cassandra**, which is being used by major companies like Netflix, Comcast or Facebook and it's known for being highly scalable.

In order to work, the Apenode needs to have both these components set up and operational. A typical Apenode installation can be summed up with the following picture:

[[IMAGE OF ARCHITECTURE, SHOWING A DETAILED PROXY SERVER, CASSANDRA, ETC]]

The API Plugin Server is the component that will actually process the API requests and execute the configured plugins to provide additional functionalities.

The proxy server also offers an internal API that it can be used to configure the Apenode, create new users, and other operations. This makes it extremely easy to integrate the Apenode with existing systems, and it also enables beautiful user experiences: for example when implementing an api key provisioning flow, a website can directly communicate with the Apenode for the credentials provisioning.






