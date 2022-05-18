### Introspection : A way of examining where a contract support certain interface(s) or not. 
### See: Type Introspection - https://en.wikipedia.org/wiki/Type_introspection
### Ref: https://docs.openzeppelin.com/contracts/2.x/api/introspection

Two types of introspection:
1. Local
    - Locally a contract implements IERC165 and declares an interface (one way of doing this is overriding supportsInterface() from ERC165 and return desired results), And queries can be done via ERC165Checker  
2. Global
    - A global and unique registry (IERC1820Registry) that is used to register implementers of a certain interface (IERC1820Implementer). Then the registry can be queried. Allows more complex setups like contracts implementing interfaces for externally-owned accounts

I'll create two branches to examine both types in the case of EXPerience ERC20 token/NFT
dev/introspection_local
dev/introspection_global

- [ ] Some gas comparisons and trade-offs once I implement both.