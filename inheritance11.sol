// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Inheritance {
    address public owner; 
    uint256 public lastAlive; //เก็บเวลาที่สัญญาถูกเรียกใช้ครั้งล่าสุด โดยกำหนดค่าเริ่มต้นใน constructor ด้วยเวลาเมื่อสร้างสัญญา
    Inheritor[] public inheritors;

    struct Inheritor {
        address payable inheritorAddress;
        string name;
        uint256 percentage; // เปอร์เซ็นต์มรดก
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        lastAlive = block.timestamp;
    }

    // 1. เติมเงินลงในกองทุน
    function addFunds() external payable {}

    // 2. ดูยอดเงินในกองทุน
    function viewPoolBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // 3. เพิ่มผู้รับมรดก
    function addInheritor(address payable inheritorAddress, string calldata name, uint256 percentage) external onlyOwner {
    require(percentage > 0, "Percentage must be greater than 0");
    inheritors.push(Inheritor(inheritorAddress, name, percentage));
}



    // 4. ลบผู้รับมรดก
    function removeInheritor(address inheritorAddress) external onlyOwner {
        for (uint256 i = 0; i < inheritors.length; i++) {
            if (inheritors[i].inheritorAddress == inheritorAddress) {
                inheritors[i] = inheritors[inheritors.length - 1];
                inheritors.pop();
                break;
            }
        }
    }

    // 5. ดูรายชื่อผู้รับมรดก
    function viewInheritors() external view returns (Inheritor[] memory) {
        return inheritors;
    }

    // 6. แจกจ่ายมรดกตามเปอร์เซ็นต์ที่กำหนด
    function distributeInheritance() external onlyOwner {
        uint256 totalBalance = address(this).balance;
        uint256 totalPercentage = 0;

        // ตรวจสอบว่าผู้รับมรดกทั้งหมดมีเปอร์เซ็นต์รวมเป็น 100%
        for (uint256 i = 0; i < inheritors.length; i++) {
            totalPercentage += inheritors[i].percentage;
        }
        require(totalPercentage == 100, "Total percentage must be 100");

        // แจกจ่ายเงินมรดกตามเปอร์เซ็นต์
        for (uint256 i = 0; i < inheritors.length; i++) {
            uint256 amount = (totalBalance * inheritors[i].percentage) / 100;
            inheritors[i].inheritorAddress.transfer(amount);
        }
    }

    // 7. รักษาสัญญาให้คงอยู่ ("keep alive")
    function keepAlive() external onlyOwner {
        lastAlive = block.timestamp;
    }

    // 8. ตรวจสอบว่ามีการ keep alive
    function isAlive() external view returns (bool) {
        return (block.timestamp - lastAlive) < 365 days;
    }
}
