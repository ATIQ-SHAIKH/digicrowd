// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

//This contract deals with transfer of eth coins and not tokens!!!
contract digicrowd {
    address public baseContract;

    //Executes when deployed
    constructor() {
        baseContract = address(this);
    }

    //Structure of the block
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        string[]  image;
        address[] donators;
        uint256[] donations;
        ERC20  token;
    }

    mapping(uint256 => Campaign) public campaigns; //takes Id of the campaign and returns the details of the campaign

    //When deployed, Initialized to 0
    uint256 public numberOfCampaigns = 0;

    //To create campaign
    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string[] memory _image,
        ERC20 _token
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        // is everything okay?
        require(
            campaign.deadline < block.timestamp,
            "The deadline should be a date in the future."
        );

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;
        campaign.token = _token;
        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    //returns all campaigns
    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    //returns a specific campaign
    function getCampaign(uint256 campaignId)
        public
        view
        returns (Campaign memory)
    {
        return campaigns[campaignId];
    }

    // To check balance of an address
    function balanceOf(address account) public view returns (uint256) {
        return account.balance;
    }

    // Contract transfers the funds to fundraiser
    function donateToCampaign(
        uint256 _id
    ) public payable {
        Campaign storage campaign = campaigns[_id];
        uint256 _amount = msg.value;
        require(baseContract.balance >= _amount, "Transaction failed 106!!!");

        (bool sent, ) = payable(campaign.owner).call{value: _amount}("");

        require(sent, "Transaction failed 110!!!");
        if(sent){
        campaign.amountCollected = campaign.amountCollected + _amount;
        campaign.donators.push(msg.sender);

        campaign.donations.push(_amount);
        }
    }

    // Investor transfers to contract
    event Received(address, uint256);

    function transferERC20(uint256 _id,address from, uint256 amount) public {
        // require(msg.sender === owner, "Only owner can withdraw funds");
        uint256 erc20balance = campaign.token.balanceOf(address(this));
        require(amount <= erc20balance, "balance is low");
        campaign.token.transfer(to, amount);
        emit TransferSent(from, to, amount);
        campaign.amountCollected = campaign.amountCollected + amount;
        campaign.donators.push(from);

        campaign.donations.push(amount);
    }
}
