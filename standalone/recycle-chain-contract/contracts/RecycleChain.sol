// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/utils/Strings.sol";

contract RecycleChain {
    uint256 public productCounter;
    address payable public owner;

    constructor() {
        productCounter = 0;
        owner = payable(msg.sender);
    }


    enum ProductState { Manufactured, Solid, Returned, Recycled }

    struct Product {
        uint256 id;
        string name;
        uint256 quantity;
        address manufacturer;
        ToxicItem[] toxicItems;
    }


    struct ToxicItem {
      string name;
      uint256 weight;
    }


    struct ProductItem {
      string id;
      uint256 productId;
      ProductState state;
    }


    struct Manufacturer {
      string name;
      string location;
      string contact;
    }
      
  mapping(uint256 => Product) public products;
  mapping(string => ProductItem) public productItems;
  mapping(address => string[]) public inventory;
  mapping(address => Manufacturer) public manufacturers;  


  event ProductCreated(uint256 indexed productId, string name, address manufacturer);
  event ToxicItemCreated(uint256 indexed productId, string name, uint256 weight);
  event ProductItemAdded(string [] itemIds, uint256 productId);
  event ProductItemsStateChanged(string [] itemIds, ProductState newState);
  event ManufacturerRegistered(address indexed manufacturer, string name, string location, string contact);



  function registerManufacturer(string memory _name, string memory _location, string memory _contact) public {
    require(bytes(_name).length > 0, "Name is required");
    require(bytes(manufacturers[msg.sender].name).length == 0, "Manufacturer already registered");

   Manufacturer memory newManufacturer = Manufacturer({
      name: _name,
      location: _location,
      contact: _contact
    });

    manufacturers[msg.sender] = newManufacturer;

    emit ManufacturerRegistered(msg.sender, _name, _location, _contact);
  }


  function addProduct(
    string memory _name,
    string[] memory _toxicNames,
    uint256[] memory _toxicWeights
   ) public {
    require(bytes(_name).length > 0, "Product name is required");
    require(_toxicNames.length == _toxicWeights.length, "Toxic items array length mismatch");
    require(bytes(manufacturers[msg.sender].name).length > 0, "Only registered manufacturers can add products");

    productCounter++;
    uint256 newProductId = productCounter;

    Product storage newProduct = products[newProductId];
    newProduct.id = newProductId;
    newProduct.name = _name;
    newProduct.quantity = 0;
    newProduct.manufacturer = msg.sender;

    emit ProductCreated(newProductId, _name, msg.sender);

    for (uint256 i = 0; i < _toxicNames.length; i++) {
      ToxicItem memory newToxicItem = ToxicItem({
        name: _toxicNames[i],
        weight: _toxicWeights[i]
      });
      newProduct.toxicItems.push(newToxicItem);
      emit ToxicItemCreated(newProductId, _toxicNames[i], _toxicWeights[i]);
    }
   }

  function addProductItems(uint256 _productId, uint256 _quantity) public {
    require(_quantity <= 10, "Cannot add more than 10 product items at a time");
    require(products[_productId].id != 0, "Product does not exist");
    require(products[_productId].manufacturer == msg.sender, "Only the manufacturer can add product items");

    string[] memory newProductItemIds = new string[](_quantity);

    for (uint256 i = 0; i < _quantity; i++) {
      string memory newItemId = string(
        abi.encodePacked(
          Strings.toString(_productId),
          "-",
          Strings.toString(products[_productId].quantity + 1)
        )
      );

      ProductItem memory newProductItem = ProductItem({
        id: newItemId,
        productId: _productId,
        state: ProductState.Manufactured
      });

      productItems[newItemId] = newProductItem;
      inventory[msg.sender].push(newItemId);
      newProductItemIds[i] = newItemId;
      products[_productId].quantity++;
    }

    emit ProductItemAdded(newProductItemIds, _productId);
  }

  function sellProductItems(string[] memory _itemIds) public {
    for (uint256 i = 0; i < _itemIds.length; i++) {
      string memory itemId = _itemIds[i];
      ProductItem storage item = productItems[itemId];
      require(item.productId != 0, "Product item does not exist");
      require(item.state == ProductState.Manufactured, "Only manufactured items can be sold");

      item.state = ProductState.Solid;
    }

    emit ProductItemsStateChanged(_itemIds, ProductState.Solid);
  }

  function returnProductItems(string[] memory _itemIds) public {
    for (uint256 i = 0; i < _itemIds.length; i++) {
      string memory itemId = _itemIds[i];
      ProductItem storage item = productItems[itemId];
      require(item.productId != 0, "Product item does not exist");
      require(item.state == ProductState.Solid, "Only solid items can be returned");

      item.state = ProductState.Returned;
    }

    emit ProductItemsStateChanged(_itemIds, ProductState.Returned);
  }

  function recycleProductItems(string[] memory _itemIds) public {
    for (uint256 i = 0; i < _itemIds.length; i++) {
      string memory itemId = _itemIds[i];
      ProductItem storage item = productItems[itemId];
      require(item.productId != 0, "Product item does not exist");
      require(item.state == ProductState.Returned, "Only returned items can be recycled");

      item.state = ProductState.Recycled;
    }

    emit ProductItemsStateChanged(_itemIds, ProductState.Recycled);
  }
  
}