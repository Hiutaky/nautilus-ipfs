import { ethers } from "ethers"
import { exec } from "child_process"
import ERC721Abi from "./abi/ERC721.json"

const RPC = "https://cronos-testnet-3.crypto.org:8545/"
const contractAddress = "0x71740E48c091EF3b5b35f213b92E3aEF1925B010"
const imageExt = "webp"
const eventToTrack = "Transfer"

const main = async () => {
    let tokenName = ""
    try {
        if( RPC.search('http') == -1  ) error("Provide a valid RPC")
        const provider = new ethers.providers.JsonRpcProvider(RPC)
        console.log( `🔒 Provider Ready: ${RPC}` )
        if( ! ethers.utils.isAddress(contractAddress) ) error("Provide a valid contract address")
        const contract = new ethers.Contract(
            contractAddress,
            ERC721Abi,
            provider
        )
        tokenName = await contract.name()
        console.log( `✅ ${tokenName} Contract Connected: ${contractAddress}
        `)
        if( ! searchEventInAbi(eventToTrack) ) error(`Cannot find ${eventToTrack} event into Abi`)
        console.log( `👀 Looking for "${eventToTrack}" Events on "${tokenName}":
        ` )
        contract.on( eventToTrack, async (...event) => {
            const from = event[0]
            //check if it's sent by the 0 address, so minted
            if( from == ethers.constants.AddressZero ){
                const tokenId = event[2]
                console.log( `🖼️  Minted ${tokenId}`)
                exec(`./reveal.sh ./metadata/${tokenId}.json`, (error, stdout, stderr) => {
                    if( error )
                        error(error)
                    
                    console.log(`   🔓 Reveal Metadata ${tokenId}.json`)
                })
                exec(`./reveal.sh ./images/${tokenId}.${imageExt}`, (error, stdout, stderr) => {
                    if( error )
                        error(error)
                    
                    console.log(`   🔓 Reveal Image ${tokenId}.${imageExt}`)
                })
            }
        } )
    } catch (e) {
        console.log(e)
    }
    
}

const searchEventInAbi = (eventToSearch) => {
    let exist = false
    ERC721Abi.map( (abiItem) => {
        if( abiItem.name == eventToSearch )
            exist = true
    })
    return exist
}

const error = (msg) => {
    throw `⛔️ ${msg}`
}


main()