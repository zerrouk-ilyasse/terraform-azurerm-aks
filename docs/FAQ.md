# Frequently Asked Questions

- [When do I need to specify podnet cidr block?](#when-do-i-need-to-specify-podnetcidrblock)
- [Can I deploy multiple clusters into the same subnet/vnet?](#can-i-deploy-multiple-clusters-into-the-same-subnetvnet)

## When do I need to specify `podnet_cidr_block`?

Podnet cidr block is only relevant for clusters using the [kubenet](https://docs.microsoft.com/en-us/azure/aks/concepts-network#kubenet-basic-networking) network plugin (default). This is irrelevant for clusters configured to use [Azure CNI](https://docs.microsoft.com/en-us/azure/aks/concepts-network#azure-cni-advanced-networking).

The module sets a default of `100.65.0.0/16` for the `podnet_cidr_block` variable. It's suitable to use the default value for this when only one cluster is deployed into a virtual network.

When multiple clusters are deployed into the same subnet or different subnets which share the same route table, the kubenet ranges must **not** overlap and must be managed manually. If multiple clusters are deployed into the same virtual network (with a single route table) and share overlapping podnet networks, you will experience network connectivity issues between pods hosted on different nodes in the cluster.

Where this is the case, we advise planning the address spaces used for the clusters using a pattern like the one outlined below.

| Cluster name | Podnet cidr block |
| :----------: | :---------------: |
|    aks-1     |   100.65.0.0/16   |
|    aks-2     |   100.66.0.0/16   |
|    aks-3     |   100.67.0.0/16   |

## Can I deploy multiple clusters into the same subnet/vnet?

In short; yes, but it's not advised for clusters using the kubenet network plugin.

Microsoft advise against this deployment pattern in the [limitations of kubenet documentation](https://docs.microsoft.com/en-us/azure/aks/configure-kubenet#limitations--considerations-for-kubenet). This is due to route tables not having write locks and therefore not able to be modified by more than one AKS cluster when new nodes are created. If multiple clusters scale out at exactly the same time, the route table entry for the new node can be overwritten. The Cloud Controller Manager will reconcile after this event (likely before the node boots and becomes available to schedule pods).

Despite Microsoft's guidance it is possible to run multiple clusters in a single subnet, we wouldn't advise doing this when the clusters are important but we haven't seen any significant issues in doing so (on clusters where scaling events aren't too common). For this to work we need to use the `podnet_cidr_block` to make sure that each cluster isn't using the same CIDR for pod IPs.

Ideally, each kubenet AKS cluster should have it's own subnet and route table created using the vnet module. However, this may not be feasible or desired for all use cases.

See the [networking](/README.md#networking) section of the main readme for more information.
