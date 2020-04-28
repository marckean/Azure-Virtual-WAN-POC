# Part 3 - Tier 3
## Azure Virtual WAN POC
This **part 1** of a 5 part series of templates to deploy a glorified 3 tier Azure network

## Deployment note
While you can deploy this fully functional deployment customised to suit your needs exactly, you can also deploy this environment **as is** to have a play and have a look at what it looks like in Azure. As part of this fully functional deployment - to ensure everything remains in-tact and works - it's recommended that the first four templates are deployed in the same order as above, however it's mandatory that the last one **vNetPeerings** is deployed last, as it is required that all vNets are deployed in order for peers to be created successfully.

This 5 part series of templates is fully functional with no over-lapping address ranges, UDRs have all the correct next hop IP addresses and all the template parameters are correctly set. In order to deploy this successfully, be sure to deploy the templates to following resource groups:
- Azure-T1-Network | Resource Group **T1_01**
- Azure-T2-Network | Resource Group **T2_01**
- Azure-T3-Network | Resource Group **T3_01**
- Azure-T3plus-Network | Resource Group **T3plus_01**
- vNetPeerings | Resource Group ***Any Resource Group***

This **Tier 3** repo is to be deployed last and fills in all the relevant peers for the vNets.

