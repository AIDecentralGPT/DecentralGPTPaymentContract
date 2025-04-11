import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";


contract DecentralGPTPaymentContract is OwnableUpgradeable {

        function initialize() public initializer {
            OwnableUpgradeable.__Ownable_init();

            vipFee = 6000 ether;

           vipQuotas = 1000;
           monthCountPaySupport[1]=true;
           monthCountPaySupport[3] = true;
           monthCountPaySupport[12] = true;
        }



        IERC20Upgradeable public dgc;
        // uint public price;
        uint public vipFee;
        uint public vipQuotas; //405b=1000,other=10k
  
        mapping (address => uint) public vipExpirationDates; 
        mapping (address => mapping (uint => uint)) public timesRequested; // ->day->type->count
        mapping (uint => bool) public monthCountPaySupport;

        function setVipFee(uint _fee)external onlyOwner{
            vipFee = _fee;
        }

        // function setFreeQuotas(uint _type,uint _value) external  onlyOwner {
        //     freeQuotas[_type] = _value;
        // }

        function setVipQuotas(uint _value) external onlyOwner{
            vipQuotas = _value;
        }

        function  setMonthCountPaySupport(uint _count,bool _value) external onlyOwner{
            monthCountPaySupport[_count] = _value;
            
        }

        function setDgc(address _dgc) external onlyOwner {
            dgc = IERC20Upgradeable(_dgc);
        }


        function payForVip(uint _monthCount) external  {

            // require(msg.value == amountPay(),"value error");
            require(monthCountPaySupport[_monthCount],"not support");
            dgc.transferFrom(msg.sender,address(this),amountPay(_monthCount));
            if(vipExpirationDates[msg.sender] < block.timestamp ){
                vipExpirationDates[msg.sender] = block.timestamp + 30 days * _monthCount;
            }else {
                vipExpirationDates[msg.sender] += 30 days * _monthCount;
            }

        }


        function amountPay(uint _monthCount) public view returns(uint){
             return vipFee*_monthCount;
            
        }


        function remainingAmount(address _account) public view returns(uint){
            // uint[] memory _ts = new uint[](_types.length);
            // for(uint i;i< _types.length;i++){
                uint _requested = timesRequested[_account][block.timestamp/1 days];
             uint _r = vipExpirationDates[_account] > block.timestamp ? vipQuotas - _requested : 0;
       
            // }
            return _r;

        }


        function request(uint _amount) external {
                require(_amount >0,"amount zero");
                
           uint _r = remainingAmount(msg.sender);
           require(_r >= _amount,"insufficient");
        //     for(uint i;i<_types.length;i++){
                // require(_ts[i] > 0,"zero");
                timesRequested[msg.sender][block.timestamp/ 1 days]+= _amount;
            // }

            
        }


        function withdraw() external onlyOwner {
           payable (msg.sender).transfer(address(this).balance);
        }


}


