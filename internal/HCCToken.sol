// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract HCCToken is ERC20, ERC20Detailed, Ownable {
    address private _minter;
    modifier onlyMinter() {
        require(msg.sender == _minter, "only minter");
        _;
    }
    event MinterChanged(address indexed oldMinter, address indexed newMinter);

    constructor() ERC20Detailed("HCCToken", "HCC", 18) public {
    }

    function mint(address to, uint256 amount) external onlyMinter {
        _mint(to, amount);
    }

    function minter() public view returns (address) {
        return _minter;
    }

    function changeMinter(address newMinter) public onlyOwner {
        require(newMinter != address(0), "new minter is the zero address");
        emit MinterChanged(_minter, newMinter);
        _minter = newMinter;
    }
}
