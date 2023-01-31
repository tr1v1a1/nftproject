// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "MintAnimalToken.sol";

contract SaleAnimalToken {
    MintAnimalToken public mintAnimalTokenAddress;

    constructor (address _mintAnimalTokenAddress) {
        mintAnimalTokenAddress = MintAnimalToken(_mintAnimalTokenAddress);
    }

    mapping(uint256 => uint256) public animalTokenPrices; // 가격대 관리

    uint256[] public onSaleAnimalTokenArray; // 판매중인 토큰을 표시하기 위함

    function setForSaleAnimalToken(uint256 _animalTokenId, uint256 _price) public {
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);

        require(animalTokenOwner == msg.sender, "Caller is not animal token owner."); //함수를 실행하는 사람이 토큰의 주인인가?
        require(_price > 0, "Price is zero or lower."); // 가격이 0보다 작으면 에러
        require(animalTokenPrices[_animalTokenId] == 0, "This animal token is already on sale."); // 토큰의 값이 0원일 경우 판매된 것으로 친다.
        require(mintAnimalTokenAddress.isApprovedForAll(animalTokenOwner, address(this)), "Animal token owner did not approve token.");
        // 스마트컨트랙트가 제대로 전달됬는지(판매 권한을 주었는지.)

        animalTokenPrices[_animalTokenId] = _price;

        onSaleAnimalTokenArray.push(_animalTokenId);
    }

    function purchaseAnimalToken(uint256 _animalTokenId) public payable {

        uint256 price = animalTokenPrices[_animalTokenId];
        address animalTokenOwner = mintAnimalTokenAddress.ownerOf(_animalTokenId);
        
        require(price > 0, "Animal token not safe.");
        require(price <= msg.value, "Caller sent lower than price.");
        require(animalTokenOwner != msg.sender, "Caller is animal token owner.");

        payable(animalTokenOwner).transfer(msg.value);
        
        mintAnimalTokenAddress.safeTransferFrom(animalTokenOwner, msg.sender, _animalTokenId);

        animalTokenPrices[_animalTokenId] = 0;

        for(uint256 i = 0; i < onSaleAnimalTokenArray.length; i++) {
            if(animalTokenPrices[onSaleAnimalTokenArray[i]] == 0) {
                onSaleAnimalTokenArray[i] = onSaleAnimalTokenArray[onSaleAnimalTokenArray.length - 1];
                onSaleAnimalTokenArray.pop();
            }
        }
    }

    function getOnSaleAnimalTokenArrayLength() view public returns (uint256) {
        return onSaleAnimalTokenArray.length;
    }

    function getAnimalTokenPrice(uint256 _animalTokenId) view public returns (uint256) {
        return animalTokenPrices[_animalTokenId];
    }

}