# CharityFactory: A Decentralized Donation Platform

## Overview

This project implements a `CharityFactory` smart contract that streamlines the process for charitable organizations to receive donations on the blockchain. Instead of relying on a single donation pool, this factory allows verified charities to register and automatically deploy their own dedicated `AddDonations` smart contract. Donors can then contribute Ether directly to these charity-specific donation contracts through the `CharityFactory`.

A key feature is that only the registered charity account that initiated the registration and deployment can withdraw the donated funds from their respective `AddDonations` contract, and this withdrawal is managed through the `CharityFactory`. This design promotes transparency and direct control for each charity over their raised funds.

**Note:** This project is part of a learning exercise within the Cyfrin Updraft smart contract development roadmap. While functional, it may not represent the most robust or secure implementation for a production environment. Future iterations will focus on enhancing security, testing rigor, and code quality as my skills develop through the Cyfrin Updraft course and continued practice.

## Getting Started

Follow these instructions to set up and interact with the `CharityFactory` platform within your Foundry project.

### Prerequisites

Ensure you have the following installed:

* **Foundry:** Follow the installation instructions on the [Foundry Book](https://book.getfoundry.sh/).

### Installation

1.  **Clone your repository:**
    ```bash
    git clone https://github.com/Q5-degen/CharityFactory.git
    cd CharityFactory
    ```

2.  **Install dependencies:**
    ```bash
    1.  Ensure you have [Foundry](https://book.getfoundry.sh/) installed on your system. Follow the instructions on the Foundry website for installation.

    2.  This project utilizes Chainlink price feeds for accessing real-time asset prices. Foundry will automatically handle fetching these contracts during compilation.
    ```


## Contract Summary

The platform consists of the `CharityFactory` contract, which manages the registration of charities and the deployment of individual `AddDonations` contracts.

### `CharityFactory` Contract

This contract provides the following functionalities:

* **Charity Registration:** Allows anyone to register a charitable organization by providing a unique name and a minimum donation amount. Upon registration, a new `AddDonations` contract is deployed specifically for that charity.
* **Donation Handling:** Enables users to donate Ether to a registered charity by specifying the charity's name and the donation amount. The funds are directly forwarded to the charity's dedicated `AddDonations` contract.
* **Withdrawal Management:** Allows registered charity accounts to withdraw the funds accumulated in their dedicated `AddDonations` contract. This function verifies that the caller is the registered charity account.
* **Information Retrieval:** Provides functions to query the number of donors and their addresses for a given donation contract, the balance of a donation contract, the list of all deployed donation contracts, and the owner of the `CharityFactory`.

### `AddDonations` Contract (Deployed by the Factory)

This is a separate contract deployed by the `CharityFactory` for each registered charity. Based on the `CharityFactory`'s logic, it is expected to have the following functionalities:

* **Receiving Donations:** Accepts Ether donations from users.
* **Tracking Donors:** Records the addresses of users who have donated.
* **Withdrawal by Owner:** Allows the contract owner (the registered charity account) to withdraw the accumulated donations.
