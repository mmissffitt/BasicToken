// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

contract SecondToken is IERC20 {
    string public name = "Second Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    uint256 public transferFee = 2;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public virtual override returns (bool success) {
        revertOnZeroValueTransfers(_value);
        revertOnTransferToZeroAddress(_to);
        uint256 fee = calculateFee(_value);
        require(balanceOf[msg.sender] >= _value + fee, "Insufficient balance");
        balanceOf[msg.sender] -= _value + fee;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public virtual override returns (bool success) {
        revertOnApprovalToZeroAddress(_spender);
        allowance[msg.sender][_spender] = _value;
        emit Approve(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool success) {
        revertOnZeroValueTransfers(_value);
        revertOnTransferToZeroAddress(_to);
        uint256 fee = calculateFee(_value);
        require(_value + fee <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");
        balanceOf[_from] -= _value + fee;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public virtual returns (bool success) {
        totalSupply += _value;
        balanceOf[_to] += _value;
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function burn(uint256 _value) public virtual returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    function revertOnApprovalToZeroAddress(address _spender) internal pure {
        require(_spender != address(0), "Cannot approve the zero address");
    }

    function revertOnZeroValueTransfers(uint256 _value) internal pure {
        require(_value > 0, "Cannot transfer zero value");
    }

    function revertOnTransferToZeroAddress(address _to) internal pure {
        require(_to != address(0), "Cannot transfer to the zero address");
    }

    function calculateFee(uint256 _value) internal view returns (uint256) {
        return (_value * transferFee) / 100;
    }
}
