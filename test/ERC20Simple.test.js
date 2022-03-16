const ERC20Simple = artifacts.require("ERC20Simple");


contract("ERC20Simple", (accounts) => {

    
    describe('ERC20Simple', function() {
        let token
        it('deploys', async function () {
            token = await ERC20Simple.deployed()
        })
    })
    
})