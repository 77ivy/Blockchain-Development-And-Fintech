// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract myAMM_77 {
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    uint256 public immutable conversionRate;


    //uint256 public reserve0; 
    //uint256 public reserveAll0;
    

    uint public totalSupply;
    mapping(address => uint) public reserve0;
    mapping(address => uint) public reserveAll0;


    constructor(address _token0, address _token1, uint256 _conversionRate) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);

        conversionRate = _conversionRate;

    }
    
    function trade(address tokenFrom, uint256 fromAmount) external  {

        // address tokenFrom, uint256 fromAmount
        // 假設轉換率是5000, user 給1000 token0, then user will receive 2000 token1
        // 1000*1/5000/10000 token1

        require(address(token0) == tokenFrom || address(token1) == tokenFrom, "NO!!");

        bool flg = false;

        //0 -> token0
        if(tokenFrom == address(token0)) flg = false;
        else flg = true;

        uint256 temp; // transfer_token
    
        if(flg == false){

            temp = fromAmount * 10000 / conversionRate; 
            token0.transferFrom(msg.sender, address(this), fromAmount);
            token1.transfer(msg.sender, temp);

        }
        else{

            temp = fromAmount * conversionRate / 10000; 
            token1.transferFrom(msg.sender, address(this), fromAmount);
            token0.transfer(msg.sender, temp);
        }


    }

    function provideLiquidity(uint256 token0Amount, uint256 token1Amount) external{

        if(token0.balanceOf(address(this)) == 0 && token1.balanceOf(address(this)) == 0){
            token0.transferFrom(msg.sender, address(this), token0Amount);
            token1.transferFrom(msg.sender, address(this), token1Amount);
        }
        else{
            uint256 _token0 = token0.balanceOf(address(this));
            uint256 _token1 = token1.balanceOf(address(this));

        
            if(_token1 *token0Amount  /_token0   <= token1Amount ){
                token0.transferFrom(msg.sender, address(this), token0Amount);
                token1.transferFrom(msg.sender, address(this), _token1 *token0Amount / _token0);
                reserve0[msg.sender] = token0Amount;
                reserveAll0[msg.sender] = _token0 + token0Amount;
            }
            else{
                token0.transferFrom(msg.sender, address(this), _token0 *token1Amount / _token1);
                token1.transferFrom(msg.sender, address(this), token1Amount);
                reserve0[msg.sender] = _token0 *token1Amount / _token1;
                reserveAll0[msg.sender] = _token0 *token1Amount / _token1 + _token0; 
            }
        }
        
    }
    
    function withdrawLiquidity() external{

        token0.transfer(msg.sender, token0.balanceOf(address(this)) * reserve0[msg.sender] / reserveAll0[msg.sender]);
        token1.transfer(msg.sender, token1.balanceOf(address(this)) * reserve0[msg.sender] / reserveAll0[msg.sender]);
    }
}