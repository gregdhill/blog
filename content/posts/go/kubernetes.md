+++
title = "Let's Go Kubernetes"
date = "2019-04-27"
author = "Gregory Hill"
tags = [
    "go",
    "kubernetes",
]
+++

Welcome to the first post from what will hopefully become a series on my adventures with Go! I'm really lucky to be able to experiment with some super awesome 
technologies which I will endeavour to write about more, so if you find this post helpful please let me know on [twitter](https://twitter.com/gregorydhill)!

![Kubernetes Logo](/img/kubernetes.png)

If you're new to Go, follow the [getting started docs](https://golang.org/doc/install). You'll also need to configure access to a Kubernetes cluster, 
or install [Minikube](https://kubernetes.io/docs/setup/minikube/) - a single local node. In the process of setting this up you will likely install
`kubectl`, though not strictly necessary for this introduction, I would first recommend you explore what it can do. Well known developer, Kelsey Hightower - 
co-author of "[Kubernetes: Up and Running](http://shop.oreilly.com/product/0636920043874.do)" - famously coined this particular tool as the [new SSH](https://twitter.com/kelseyhightower/status/1070413458045202433).
It is the main gateway into the world of container orchestration, and before continuing with this post I highly recommend exploring what it can do as it 
underpins a lot of what we are going to talk about. I also encourage you to learn the distinctions between common Kubernetes object types, as some of the
terminology that follows may prove unfamiliar.

## Getting Started

There are a number of well-maintained libraries provided for us so let's get stuck in. If you're using [Go modules](https://github.com/golang/go/wiki/Modules)
this step shouldn't be necessary, though you may have to initialize the project directory first: `go mod init`.

```bash
go get -u k8s.io/client-go/...
go get -u k8s.io/apimachinery/...
```

Let's create our starting file, `main.go` and copy in the following text:

```go
package main

import (
	"log"
	"os"
	"fmt"
	"path/filepath"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"

	// import all auth plugins
	_ "k8s.io/client-go/plugin/pkg/client/auth"
)

// this is the entry point for our program
func main() {
	// find the location of our config
	home := filepath.Join(os.Getenv("HOME"), ".kube", "config")
	// note: if home is empty, the following helper function
	// will try to fetch the default in-cluster setup
	config, err := clientcmd.BuildConfigFromFlags("", home)
	if err != nil {
		log.Fatal(err)
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		log.Fatal(err)
	}

	// get a list of all namespaces and iterate the names
	ns, _ := clientset.Core().Namespaces().List(metav1.ListOptions{})
	for _, n := range ns.Items {
		fmt.Println(n.Name)
	}
}
```

Save this file, then to compile and run it in one step (assuming you're in the same directory):

```bash
go run .
```

In the (unlikely) event that everything worked first time you should see a list of namespaces in your cluster. However,
if you've only just provisioned your cluster, you will not see anything - don't panic! Let's go ahead ask our app to
create a namespace. Adapt the above code with the following; add a new import, then call the function `createNamespace` 
to perform a new query against the Kubernetes API. Please note that for the sake of brevity these snippets will not handle 
all errors gracefully, so please ensure to add the appropriate checks before deploying to production!

```go
import (
	...
	corev1 "k8s.io/api/core/v1"
	...
)

func createNamespace(clientset kubernetes.Interface, name string) error {
	ns := &corev1.Namespace{ObjectMeta: metav1.ObjectMeta{Name: name}}
	// we only care if it errors
	_, err := clientset.Core().Namespaces().Create(ns)
	return err
}

func main() {
	...

	err := createNamespace(clientset, "test-namespace")
	if err != nil {
		log.Fatal(err)
	}

	ns, _ := clientset.Core().Namespaces().List(metav1.ListOptions{})
	for _, n := range ns.Items {
		fmt.Println(n.Name)
	}
}
```

You should now see `test-namespace` in your output. To verify this object has been successfully created in your cluster:

```bash
kubectl get namespaces
```

![Gotta catch 'em all](/img/pokemon.png)

## Testing

Note the first argument in the new function `createNamespace` above, of type `kubernetes.Interface` - defined in `k8s.io/client-go/kubernetes`. The helper
function `kubernetes.NewForConfig(config)` previously gave us a `client` that satisfied this interface, meaning it implemented all required methods of the type.
In this case, as part of the `Core` API, we retrieved a `Namespaces` interface which itself contained the methods `Create` and `List`. Using the pre-configured 
REST client, the library handles requests to your remote cluster's API formed from the given parameters. 

What if you were to satisfy the interface another way? Perhaps you could match all method signatures without actually sending those requests and altering the state
of your cluster. That is exactly what has been implemented in `k8s.io/client-go/kubernetes/fake`, using a simple object tracker that reports the state of it's in-memory 
cluster representation. This enables us to easily unit test our code with far less overhead:

```go
package main

import (
	"testing"
	"k8s.io/client-go/kubernetes/fake"
)

func TestCreateNamespace(t *testing.T) {
	client := fake.NewSimpleClientset()
	err := createNamespace(client, "test")
	if err != nil {
		t.Fatal(err)
	}
}
```

Save this as `main_test.go` in the same directory as before and run the test:

```bash
go test .
```

## Next

I'm afraid that's all for now, but I will be adding to this post again soon. Possible topics include:

* Proxies
* Typed vs Dynamic
* CustomResourceDefinitions

![Mining Gopher - Under Construction](/img/mining_gopher.jpeg)

