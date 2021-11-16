import chai from 'chai'
import { expect } from 'chai'
import { ethers, network } from 'hardhat'
import { solidity } from 'ethereum-waffle'
import { ArrayProxy__factory } from '../typechain'

chai.use(solidity)

describe('Array', async () => {
  let contractAddress: string

  beforeEach(async () => {
    const [deployer] = await ethers.getSigners()
    const arrayProxyFactory = new ArrayProxy__factory(deployer)
    const arrayProxyContract = await arrayProxyFactory.deploy()
    contractAddress = arrayProxyContract.address
  })

  it('Should erase parking spot', async () => {
    const [deployer] = await ethers.getSigners()
    const arrayProxy = new ArrayProxy__factory(deployer).attach(contractAddress)

    await arrayProxy.insertSpot()
    expect(await arrayProxy.size()).to.equal(1)

    await arrayProxy.erase(0)
    expect(await arrayProxy.size()).to.equal(0)
  })

  it('Should throw if index out of range', async () => {
    const [deployer] = await ethers.getSigners()
    const arrayProxy = new ArrayProxy__factory(deployer).attach(contractAddress)

    await expect(arrayProxy.erase(1)).to.be.revertedWith('Out of range')
  })
})
