// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./SafeMath.sol";
import "./StringUtils.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StablePriceOracle.sol";
import "./UniversalRegistrar.sol";

// SLDPriceOracle sets a price in USD, based on an oracle for each node.
// The registry can set and change default and specific tld prices
contract SLDPriceOracle is Ownable {
    using SafeMath for *;
    using StringUtils for *;

    // Base price units by length. Element 0 is for 1-length names, and so on.
    uint256[] public defaultPrices;
    mapping(bytes32 => uint256[]) public prices;

    mapping(uint256 => mapping(bytes32 => mapping(bytes32 => uint256))) public premiumPrices;
    mapping(bytes32 => uint256) public premiumPricesVersion;

    // Oracle address
    AggregatorInterface public usdOracle;
    // Registrar address
    UniversalRegistrar public registrar;
    
    event OracleChanged(address oracle);

    event NamePremium(bytes32 indexed node, string name, uint256 price);
    event PremiumsCleared(bytes32 indexed node);
    event PriceChanged(bytes32 node, uint256[] prices);
    event DefaultPriceChanged(uint256[] prices);

    bytes4 private constant INTERFACE_META_ID =
    bytes4(keccak256("supportsInterface(bytes4)"));

    bytes4 private constant ORACLE_ID =
    bytes4(keccak256("price(bytes32,string)"));

    constructor(UniversalRegistrar _registrar, AggregatorInterface _usdOracle, uint256[] memory _defaultPrices) {
        registrar = _registrar;
        usdOracle = _usdOracle;
        defaultPrices = _defaultPrices;
    }

    function price(bytes32 node, string calldata name) external view returns (uint256) {
        bytes32 label = keccak256(bytes(name));

        // if a premium price exists, return it
        if (premium(node,label) != 0) {
            uint256 basePremium = premium(node, label);
            return attoUSDToWei(basePremium);
        }

        uint256 len = name.strlen();
        uint256[] memory _prices = prices[node].length > 0 ? prices[node] : defaultPrices;

        if (len > _prices.length) {
            len = _prices.length;
        }

        require(len > 0, "Name has no Length");

        uint256 basePrice = _prices[len - 1];
        return attoUSDToWei(basePrice);
    }

    function attoUSDToWei(uint256 amount) internal view returns (uint256) {
        uint256 ethPrice = uint256(usdOracle.latestAnswer()); //2
        return amount.mul(1e8).div(ethPrice);
    }

    function weiToAttoUSD(uint256 amount) internal view returns (uint256) {
        uint256 ethPrice = uint256(usdOracle.latestAnswer());
        return amount.mul(ethPrice).div(1e8);
    }

    function premium(bytes32 node, bytes32 label) public view returns (uint256) {
        return premiumPrices[premiumPricesVersion[node]][node][label];
    }

    /**
     * @dev Set USD Oracle
     * @param _usdOracle USD Oracle
     */
    function setUSDOracle(AggregatorInterface _usdOracle) public onlyOwner {
        usdOracle = _usdOracle;
        emit OracleChanged(address(_usdOracle));
    }

    /**
     * @dev Sets the price for a specific name.
     * @param node The node to set the price for.
     * @param name The name to set the price for.
     * @param _price The price. Values are in base
     * price units, equal to one attodollar (1e-18 dollar)
     * each (zero values will clear the price premium).
     */
    function setPremium(bytes32 node, string calldata name, uint256 _price) external onlyOwner {
        bytes32 label = keccak256(bytes(name));
        premiumPrices[premiumPricesVersion[node]][node][label] = _price;
        emit NamePremium(node, name, _price);
    }

    function setPremiums(bytes32 node, string[] calldata names, uint256[] calldata _prices) external onlyOwner {
        require(names.length == _prices.length, "names and prices must have the same length");
        for (uint i = 0; i < names.length; i++) {
            bytes32 label = keccak256(bytes(names[i]));
            premiumPrices[premiumPricesVersion[node]][node][label] = _prices[i];
            emit NamePremium(node, names[i], _prices[i]);
        }
    }

    function clearPremiums(bytes32 node) external onlyOwner {
        premiumPricesVersion[node]++;
        emit PremiumsCleared(node);
    }

    /**
     * @dev Sets prices for the specified node (can only be called by the node owner)
     * @param _prices The price array. Each element corresponds to a specific
     *                    name length; names longer than the length of the array
     *                    default to the price of the last element. Values are
     *                    in base price units, equal to one attodollar (1e-18
     *                    dollar) each.
     */
    function setPrices(bytes32 node, uint256[] memory _prices) public onlyOwner {
        prices[node] = _prices;
        emit PriceChanged(node, _prices);
    }

    /**
     * @dev Sets default prices to be used by nodes that don't have pricing set.
     * @param _defaultPrices The price array. Each element corresponds to a specific
     *                    name length; names longer than the length of the array
     *                    default to the price of the last element. Values are
     *                    in base price units, equal to one attodollar (1e-18
     *                    dollar) each.
     */
    function setDefaultPrices(uint256[] memory _defaultPrices) public onlyOwner {
        defaultPrices = _defaultPrices;
        emit DefaultPriceChanged(_defaultPrices);
    }

    function supportsInterface(bytes4 interfaceID) public view virtual returns (bool)
    {
        return interfaceID == INTERFACE_META_ID || interfaceID == ORACLE_ID;
    }
}