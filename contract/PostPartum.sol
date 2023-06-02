// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LilypadEventsUpgradeable.sol";
import "./LilypadCallerInterface.sol";

contract PostPartumV2 is LilypadCallerInterface, Ownable {
    address public bridgeAddress;
    LilypadEventsUpgradeable bridge;
    uint256 public lilypadFee; //=30000000000000000;
    // 40000000000000000

    struct Results {
        address caller;
        string prompt;
        string standardOutput;
    }
    Results[] public result;
    mapping(uint256 => string) prompts;

    // event NewImageGenerated(StableDiffusionImage image);
    event NewResult(Results image);

    constructor(address _bridgeContractAddress) {
        console.log("Deploying PostPartum contract");
        bridgeAddress = _bridgeContractAddress;
        bridge = LilypadEventsUpgradeable(_bridgeContractAddress);
        uint fee = bridge.getLilypadFee();
        lilypadFee = fee;
    }

    function setBridgeAddress(address _newAddress) public onlyOwner {
        bridgeAddress = _newAddress;
    }

    function setLPEventsAddress(address _eventsAddress) public onlyOwner {
        bridge = LilypadEventsUpgradeable(_eventsAddress);
    }

    function getLilypadFee() external {
        uint fee = bridge.getLilypadFee();
        console.log("fee", fee);
        lilypadFee = fee;
    }

    function setLilypadFee(uint256 _fee) public onlyOwner {
        require(_fee > 0, "Lilypad fee must be greater than 0");
        lilypadFee = _fee;
    }

    string constant specStart =
        "{"
        '"Engine": "docker",'
        '"Verifier": "noop",'
        '"PublisherSpec": {"Type": "estuary"},'
        '"Docker": {'
        '"Image": "hakymulla/chainlink:inference",'
        '"Entrypoint": ["python", "Inference.py"';

    string[] params = [
        "--ag",
        "--t",
        "--i",
        "--n",
        "--c",
        "--l",
        "--g",
        "--b",
        "--s"
    ];

    string constant specEnd =
        "]},"
        '"Resources": {"CPU": "1"},'
        '"Outputs": [{"Name": "outputs", "Path": "/outputs"}],'
        '"Deal": {"Concurrency": 1}'
        "}";

    function PostPartum(string[9] memory _values) external payable {
        require(msg.value >= lilypadFee, "Not enough to run Lilypad job");
        // TODO: do proper json encoding, look out for quotes in _prompt
        string memory _prompt;
        uint256 i = 0;
        for (i = 0; i < _values.length; i++) {
            _prompt = string(
                abi.encodePacked(
                    _prompt,
                    string(
                        abi.encodePacked(
                            ",",
                            '"',
                            params[i],
                            '"',
                            ",",
                            '"',
                            _values[i],
                            '"'
                        )
                    )
                )
            );
        }
        string memory spec = string(
            abi.encodePacked(specStart, _prompt, specEnd)
        );

        uint id = bridge.runLilypadJob{value: lilypadFee}(
            address(this),
            spec,
            uint8(LilypadResultType.StdOut)
        );

        require(id > 0, "job didn't return a value");
        prompts[id] = _prompt;
    }

    function allResult() public view returns (Results[] memory) {
        return result;
    }

    function lilypadFulfilled(
        address _from,
        uint _jobId,
        LilypadResultType _resultType,
        string calldata _result
    ) external override {
        //need some checks here that it a legitimate result
        require(_from == address(bridge)); //really not secure
        require(_resultType == LilypadResultType.StdOut);

        Results memory res = Results({
            caller: msg.sender,
            standardOutput: _result,
            prompt: prompts[_jobId]
        });
        result.push(res);
        emit NewResult(res);
        delete prompts[_jobId];
    }

    function lilypadCancelled(
        address _from,
        uint256 _jobId,
        string calldata _errorMsg
    ) external override {
        require(_from == address(bridge)); //really not secure
        console.log(_errorMsg);
        delete prompts[_jobId];
    }
}

// ["18", "Maybe", "Yes", "No", "Yes", "No", "Yes", "Yes", "Yes"]
