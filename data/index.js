const IPFS = require('ipfs-api');
const fs = require('fs');

// Connect to IPFS daemon running on localhost
const ipfs = new IPFS({ host: '127.0.0.1', port: '5001', protocol: 'http' });

// Function to upload a file to IPFS
async function uploadFileToIPFS(filePath) {
    try {
        const fileContent = fs.readFileSync(filePath);
        const filesAdded = await ipfs.add([{ path: filePath, content: fileContent }]);
        console.log('File uploaded to IPFS:', filesAdded[0].hash);
    } catch (error) {
        console.error('Error uploading file to IPFS:', error);
    }
}


const csvFilePath = 'train_data.csv';
uploadFileToIPFS(csvFilePath);
