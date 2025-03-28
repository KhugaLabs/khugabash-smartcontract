/**
 * Generate a base64-encoded contract URI for your NFT collection
 * @param {Object} metadata - Collection metadata
 * @returns {string} The full data URI to set in your contract
 */
function generateContractURI(metadata) {
    // Convert the metadata object to a JSON string
    const jsonMetadata = JSON.stringify(metadata);

    // Convert to base64
    const base64Metadata = Buffer.from(jsonMetadata).toString('base64');

    // Return the complete data URI
    return `data:application/json;base64,${base64Metadata}`;
}

// Example usage
const collectionMetadata = {
    name: "Khuga Bash Ktridge Collection",
    description: "Collect unique Ktridge NFTs from defeating bosses in Khuga Bash.",
    image: "https://khuga.io/images/ktridge-collection-logo.png",
    external_link: "https://khuga.io",
    seller_fee_basis_points: 250, // 2.5% royalty
    fee_recipient: "0xBE8665369c99Be217c7C37D0078e3f8a6F76d683",
    banner_image_url: "https://khuga.io/images/ktridge-collection-banner.png",
    twitter_username: "khugaverse",
    discord_url: "https://discord.gg/khuga",
};

const contractURI = generateContractURI(collectionMetadata);
console.log("Contract URI to set:");
console.log(contractURI);