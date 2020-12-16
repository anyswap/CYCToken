// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract CYCToken is Ownable {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address private _mintInvoker;
    address private _rebaseInvoker;
    uint256 private _perShareAmount;
    uint256 private _totalShares;

    mapping(address => uint256) private _shares;
    mapping(address => mapping(address => uint256)) private _allowedShares;

    modifier onlyRebaseInvoker() {
        require(
            msg.sender == _rebaseInvoker,
            "Rebase: caller is not the rebase invoker"
        );
        _;
    }

    modifier onlyMintInvoker() {
        require(msg.sender == _mintInvoker,
            "Mint: caller is not the mint invoker"
        );
        _;
    }

    constructor() public {
        _perShareAmount = 10**9;
        _totalShares = 0;
        _name = "CYCoin";
        _symbol = "CYC";
        _decimals = 18;

        _shares[msg.sender] = _totalShares;
        emit Transfer(address(0), msg.sender, _totalShares.mul(_perShareAmount));
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalShares.mul(_perShareAmount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return _shares[account].mul(_perShareAmount);
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        uint256 share = amount.div(_perShareAmount);
        _shares[msg.sender] = _shares[msg.sender].sub(share);
        _shares[recipient] = _shares[recipient].add(share);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowedShares[owner][spender].mul(_perShareAmount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowedShares[msg.sender][spender] = amount.div(_perShareAmount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        uint256 share = amount.div(_perShareAmount);
        _allowedShares[sender][msg.sender] = _allowedShares[sender][msg.sender]
            .sub(share);
        _shares[sender] = _shares[sender].sub(share);
        _shares[recipient] = _shares[recipient].add(share);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mintInvoker() public view returns (address) {
        return _mintInvoker;
    }

    function rebaseInvoker() public view returns (address) {
        return _rebaseInvoker;
    }

    function perShareAmount() public view returns (uint256) {
        return _perShareAmount;
    }

    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    function changeRebaseInvoker(address newInvoker) public onlyOwner {
        require(
            newInvoker != address(0),
            "Rebase: new invoker is the zero address"
        );
        emit RebaseInvokerChanged(_rebaseInvoker, newInvoker);
        _rebaseInvoker = newInvoker;
    }

    function rebase(
        uint256 epoch,
        uint256 numerator,
        uint256 denominator
    ) external onlyRebaseInvoker returns (uint256) {
        uint256 newPerShareAmount = _perShareAmount.mul(numerator).div(
            denominator
        );
        emit Rebase(epoch, _perShareAmount, newPerShareAmount);
        _perShareAmount = newPerShareAmount;
        return _perShareAmount;
    }

    function changeMintInvoker(address newInvoker) public onlyOwner {
        require(
            newInvoker != address(0),
            "Mint: new invoker is the zero address"
        );
        emit MintInvokerChanged(_mintInvoker, newInvoker);
        _mintInvoker = newInvoker;
    }

    function mint(address to, uint256 share) external onlyMintInvoker {
        require(to != address(0), "mint to the zero address");
        _totalShares = _totalShares.add(share);
        _shares[to] = _shares[to].add(share);
        emit Transfer(address(0), to, share.mul(_perShareAmount));
    }

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    event Rebase(
        uint256 indexed epoch,
        uint256 oldPerShareAmount,
        uint256 newPerShareAmount
    );

    event RebaseInvokerChanged(
        address indexed previousOwner,
        address indexed newOwner
    );

    event MintInvokerChanged(
        address indexed previousOwner,
        address indexed newOwner
    );
}
