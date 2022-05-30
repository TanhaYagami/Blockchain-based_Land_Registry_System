//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;


contract LandRegistrySystem{
    
    address public  LandInspectorId;
    address payable public Seller;
    address public Buyer;
    uint public LandId;
    address internal LandsOwner;
    uint internal LandPrice;
    uint internal LandArea;
    string internal LandCity;
    bool internal isBuyerVer;
    bool internal isSellerVer;


    struct landDetails{
    uint AreaInSquar;
    string City;
    string Place;
    uint landPrice;
    uint PropertyPID;
    address _LandsOwner;
    }
    mapping(uint => landDetails) public LandDetails;
    mapping(uint => string) public landCity; 
    mapping(uint => uint) public landArea; 
    mapping(uint => uint) public landPrice; 
    mapping(uint => address) public LandsCurrentOwner;
   


    struct buyerDetails{
    string Name; 
    uint Age; 
    string City; 
    uint CNIC; 
    string Email;}
    mapping(address => buyerDetails) public BuyerDetails;

     struct sellerDetails{
    string Name; 
    uint Age; 
    string City; 
    uint CNIC; 
    string Email;}
    mapping(address => sellerDetails) public SellerDetails; 

    mapping(address => bool) public isBuyerVerified; 
    mapping(address => bool) public isSellerVerified; 



    struct landInspectorDetails{
    string Name;
    uint Age;
    string Designation;}

    mapping(address => landInspectorDetails) public LandInspectorDetails; 
    
    enum landInspectorDetailsSubmission{Submited, HaventSubmited}
    landInspectorDetailsSubmission internal LandInspectorDetailsSubmission;

    enum sellerDetailsSubmission{Submited, HaventSubmited}
    sellerDetailsSubmission internal SellerDetailsSubmission;
    enum sellerVerification{verified,Rejected}
    sellerVerification internal SellerVerification;


    enum landInfoSubmission{submited,haventtSubmited}
    landInfoSubmission internal LandInfoSubmission;
    enum landVerification{verified,Rejected}
    landVerification internal LandVerification;

    enum buyerDetailsSubmission{Submited, HaventSubmited}
    buyerDetailsSubmission internal BuyerDetailsSubmission;
    enum buyerVerification{verified,Rejected}
    buyerVerification internal BuyerVerification;

    enum landStatus{OnAir, Booked, Releas, Inactive}
    landStatus internal LandStatus;


     constructor(){
        LandInspectorId = msg.sender;
    }
    modifier OnlyforLandInspactor(){
        require(msg.sender == LandInspectorId," Only the landInspector can approve this Verification");
        _;
    }
     modifier OnlyforSelller(){
        require(msg.sender == Seller," Only the Seller can call this Function");
        _;
    }
     modifier OnlyforBuyer(){
        require(msg.sender == Buyer," Only the Buyer can call this Function");
        _;
    }


     // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx STEP TWO xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 


    function LandInspectorInfo(string memory _Name, uint _Age,string memory _Designation) public OnlyforLandInspactor{
        LandInspectorDetails[msg.sender] = landInspectorDetails(_Name,_Age,_Designation); 
        LandInspectorDetailsSubmission = landInspectorDetailsSubmission.Submited;}
            

    function SellerInfo(string memory _Name, uint _Age,string memory _City, uint _CNIC,string memory _Email) public {
        SellerDetails[msg.sender] = sellerDetails(_Name,_Age,_City,_CNIC,_Email);
        Seller = payable (msg.sender);
        SellerDetailsSubmission= sellerDetailsSubmission.Submited;
          }

    function sellerVerificationInc() public OnlyforLandInspactor{
        require (SellerDetailsSubmission == sellerDetailsSubmission.Submited, "The require is not obligated ");
        SellerVerification = sellerVerification.verified;
        isSellerVer = true;}

    function LandInfo(uint _AreaInSquar,string memory _City,string memory _Place,uint _landPrice,uint _PropertyPID) public OnlyforSelller{
        require (SellerVerification == sellerVerification.verified, "The require is not obligated ");
        landDetails storage landDetailsSheet= LandDetails[LandId];
        landDetailsSheet.AreaInSquar=_AreaInSquar;
        landDetailsSheet.City=_City;
        landDetailsSheet.Place=_Place;
        landDetailsSheet.landPrice=_landPrice;
        landDetailsSheet.PropertyPID= _PropertyPID;
        landDetailsSheet._LandsOwner=msg.sender;
        LandPrice =_landPrice;
        LandsOwner=msg.sender;
        LandInfoSubmission = landInfoSubmission.submited;
        LandId++;
        }


    function landVerificationInc() public OnlyforLandInspactor{
        require (LandInfoSubmission == landInfoSubmission.submited, "The require is not obligated ");
        LandVerification= landVerification.verified;
        LandStatus = landStatus.OnAir;
    }



    function GetArea(uint EnterLandId)public{
        landArea[EnterLandId]= LandArea;
    }
    function GetLandCity(uint enterLandId)public{
        landCity[enterLandId]= LandCity;
    }
    function GetLandPrice(uint _EnterLandId)public{
        landPrice[_EnterLandId]= LandPrice;
    }
    function GetLandCurrent(uint _EnterLandID)public{
        LandsCurrentOwner[_EnterLandID]=LandsOwner;}

    function isBuyer(address EnterBuyerAddress)public{
        isBuyerVerified[EnterBuyerAddress]= isBuyerVer;
    }
     function isSeller(address EnterSellerAddress)public{
        isSellerVerified[EnterSellerAddress]= isSellerVer;
    }


     // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx STEP THREE xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 


    function BuyerInfo(string memory _Name, uint _Age,string memory _City, uint _CNIC,string memory _Email) public{
        
        require (LandVerification == landVerification.verified);
        BuyerDetails[msg.sender] = buyerDetails(_Name,_Age,_City,_CNIC,_Email); 
        BuyerDetailsSubmission= buyerDetailsSubmission.Submited;
        Buyer = msg.sender;         
    }

    function BuyerVerificationInc() public OnlyforLandInspactor{
        require (BuyerDetailsSubmission == buyerDetailsSubmission.Submited, "The require is not obligated ");
        require (LandStatus == landStatus.OnAir,"The require No.2 is not obligated ");
        BuyerVerification = buyerVerification.verified;
        isBuyerVer = true;  
    }
    
    function ConfrimationPurchasing()public payable OnlyforBuyer {
        require (LandInfoSubmission == landInfoSubmission.submited,"The require is not obligated ");
        require (BuyerDetailsSubmission == buyerDetailsSubmission.Submited,"The require No.2 is not obligated ");
        require (msg.value == LandPrice,"The amount must be Equal to the Price of Land");
        LandStatus = landStatus.Booked;
    }

    function Payments() public OnlyforBuyer {
        require (LandStatus == landStatus.Booked, "The require is not obligated ");
        Seller.transfer(address(this).balance);
        LandStatus = landStatus.Releas;
    }

    function TransferOwnership() public OnlyforSelller{
        require (LandStatus == landStatus.Releas, "The require is not obligated ");
        LandsOwner=Buyer;
        LandStatus = landStatus.Inactive;
    }
}
