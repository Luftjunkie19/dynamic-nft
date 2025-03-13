// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library PropertyCorrectnessCheckLib {
    function checkIfNotEmptyStringAndMatchesRequirements(
        string memory implementedString,
        uint256 minLength,
        uint256 maxLength
    ) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(implementedString)) !=
            keccak256(abi.encodePacked("")) &&
            bytes(implementedString).length > minLength &&
            bytes(implementedString).length < maxLength;
    }

    function contains(
        string memory text,
        string memory search
    ) public pure returns (bool) {
        bytes memory textBytes = bytes(text);
        bytes memory searchBytes = bytes(search);

        if (textBytes.length < searchBytes.length) {
            return false;
        }

        for (uint i = 0; i <= textBytes.length - searchBytes.length; i++) {
            bool found = true;
            for (uint j = 0; j < searchBytes.length; j++) {
                if (textBytes[i + j] != searchBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return true;
            }
        }

        return false;
    }
}
