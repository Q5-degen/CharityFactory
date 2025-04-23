//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {AddDonations} from "./AddDonations.sol";

error CharityFactory__MsgSenderNotRegistered();
error CharityFactory__NoDonnerYet();
error CharityFactory__NoDonnationContractCreatedYet();
error CharityFactory__DonationContractDoesntExist();

contract CharityFactory {
    address private immutable i_owner;
    AddDonations private s_addDonations;
    AggregatorV3Interface private immutable i_feed;

    struct charity {
        address _charityAccount;
        uint256 _minDonation;
        address _contractDeployed;
    }

    mapping(string _name => charity _charityInfo) private s_nameToInfo;
    string[] private s_charitiesName;
    address[] private s_registeredCharityAccounts;
    address[] private s_donationContractList;

    constructor(AggregatorV3Interface _feed) {
        i_owner = msg.sender;
        i_feed = _feed;
    }

    function register(
        string memory _charityName,
        uint256 _minDonation
    ) external {
        s_addDonations = new AddDonations(
            _minDonation,
            i_feed,
            msg.sender,
            address(this)
        ); // create a donation contract for msg.sender
        s_charitiesName.push(_charityName); // listing of the name of the charity
        s_nameToInfo[_charityName] = charity(
            msg.sender,
            _minDonation,
            address(s_addDonations)
        ); // link charity name to all revelevant infos
        s_registeredCharityAccounts.push(msg.sender); // list the charity account
        s_donationContractList.push(address(s_addDonations)); // push the new create contract into a list of conracts created
    }

    function donate(
        string memory _charityName,
        uint256 _amount
    ) external payable {
        charity memory info = s_nameToInfo[_charityName]; // retrieving relevant infos
        address donationContract = info._contractDeployed; // get the donation contract address
        AddDonations(payable(donationContract)).addDonation{value: _amount}(
            msg.sender
        ); // donate
    }

    function withdrawDonation() external {
        for (
            uint256 index = 0;
            index < s_registeredCharityAccounts.length;
            index++
        ) {
            // cheking if msg.sender is among the charities registered
            if (msg.sender == s_registeredCharityAccounts[index]) {
                for (
                    uint256 _index = 0;
                    _index < s_charitiesName.length;
                    _index++
                ) {
                    // checking the corresponding AddDonation contract address + withdraw
                    if (
                        msg.sender ==
                        s_nameToInfo[s_charitiesName[_index]]._charityAccount
                    ) {
                        address contractDeployed = s_nameToInfo[
                            s_charitiesName[_index]
                        ]._contractDeployed;
                        AddDonations(payable(contractDeployed))
                            .withdrawDonations(msg.sender);
                    }
                }
            } else {
                revert CharityFactory__MsgSenderNotRegistered();
            }
        }
    }

    function checkDonnerNumByDonationContract(
        address _donationContract
    ) public view returns (uint256 _num) {
        if (checkDonationContractListLength() == 0) {
            revert CharityFactory__NoDonnationContractCreatedYet();
        } // check if donation contract list is empty

        for (
            uint256 index = 0;
            index < s_donationContractList.length;
            index++
        ) {
            // if donation contract not empty need to  check if _donationContract exist or not
            if (_donationContract == s_donationContractList[index]) {
                _num = AddDonations(payable(_donationContract))
                    .checkNumOfDonner();
            } else {
                revert CharityFactory__DonationContractDoesntExist(); // in case it doesnt exist
            }
        }
    }

    function checkDonationContractBal(
        address _donationContract
    ) public view returns (uint256 _bal) {
        if (checkDonationContractListLength() == 0) {
            revert CharityFactory__NoDonnationContractCreatedYet();
        } // check if donation contract list is empty

        for (
            uint256 index = 0;
            index < s_donationContractList.length;
            index++
        ) {
            // if donation contract not empty need to  check if _donationContract exist or not

            if (_donationContract == s_donationContractList[index]) {
                _bal = _donationContract.balance;
            } else {
                revert CharityFactory__DonationContractDoesntExist(); // in case it doesnt exist
            }
        }
    }

    function checkDonnerAddressesByDonationContract(
        address _donationContract,
        uint256 _index
    ) public view returns (address _donnerAddr) {
        if (checkDonationContractListLength() == 0) {
            revert CharityFactory__NoDonnationContractCreatedYet();
        } // check if donation contract list is empty
        for (
            uint256 index = 0;
            index < s_donationContractList.length;
            index++
        ) {
            // if donation contract list  not empty need to  check if _donationContract exist or not
            if (_donationContract == s_donationContractList[index]) {
                if (
                    checkDonnerNumByDonationContract(
                        payable(_donationContract)
                    ) == 0
                ) {
                    revert CharityFactory__NoDonnerYet();
                }
                _donnerAddr = AddDonations(payable(_donationContract))
                    .checkDonnerAddr(_index);
            } else {
                revert CharityFactory__DonationContractDoesntExist();
            }
        }
    }

    function checkDonationContractListLength()
        public
        view
        returns (uint256 _length)
    {
        _length = s_donationContractList.length;
    }

    function checkCharityFactoryOwner() external view returns (address _owner) {
        _owner = i_owner;
    }

    function getDonationContractAddress(
        uint256 _index
    ) external view returns (address _addr) {
        uint256 donationContractListLength = checkDonationContractListLength();
        if (donationContractListLength == 0)
            revert CharityFactory__DonationContractDoesntExist();
        if (_index >= donationContractListLength)
            revert CharityFactory__DonationContractDoesntExist();

        _addr = s_donationContractList[_index];
    }
}
