import chai from 'chai'
import { expect } from 'chai'
import { ethers, network } from 'hardhat'
import { solidity } from 'ethereum-waffle'
import { MappingProxy__factory } from '../typechain'

chai.use(solidity)

describe('Mapping', async () => {
  let contractAddress: string

  beforeEach(async () => {
    const [deployer] = await ethers.getSigners()
    const mappingProxyFactory = new MappingProxy__factory(deployer)
    const mappingProxyContract = await mappingProxyFactory.deploy()
    contractAddress = mappingProxyContract.address
  })

  describe('Insert', async () => {
    it('Should insert key value pair', async () => {
      const [deployer] = await ethers.getSigners()
      const mappingProxy = new MappingProxy__factory(deployer).attach(
        contractAddress,
      )

      await expect(mappingProxy.insert(deployer.address, 100)).to.emit(
        mappingProxy,
        'Inserted',
      )
      expect(await mappingProxy.get(deployer.address)).to.equal(100)
    })

    it('Should replace value if key exists', async () => {
      const [deployer] = await ethers.getSigners()
      const mappingProxy = new MappingProxy__factory(deployer).attach(
        contractAddress,
      )

      await mappingProxy.insert(deployer.address, 100)
      await expect(mappingProxy.insert(deployer.address, 200)).to.emit(
        mappingProxy,
        'Replaced',
      )
      expect(await mappingProxy.get(deployer.address)).to.equal(200)
    })
  })

  describe('Contains', async () => {
    it('Should return true if key exists', async () => {
      const [deployer] = await ethers.getSigners()
      const mappingProxy = new MappingProxy__factory(deployer).attach(
        contractAddress,
      )

      await mappingProxy.insert(deployer.address, 100)
      expect(await mappingProxy.contains(deployer.address)).to.be.true
    })

    it('Should return false if key doesn not exist', async () => {
      const [deployer] = await ethers.getSigners()
      const mappingProxy = new MappingProxy__factory(deployer).attach(
        contractAddress,
      )

      expect(await mappingProxy.contains(deployer.address)).to.be.false
    })
  })

  describe('Get', async () => {
    it('Should get value', async () => {
      const [deployer] = await ethers.getSigners()
      const mappingProxy = new MappingProxy__factory(deployer).attach(
        contractAddress,
      )

      await mappingProxy.insert(deployer.address, 100)
      expect(await mappingProxy.get(deployer.address)).to.equal(100)
    })

    it('Should throw if key does not exist', async () => {
      const [deployer] = await ethers.getSigners()
      const mappingProxy = new MappingProxy__factory(deployer).attach(
        contractAddress,
      )

      await expect(mappingProxy.get(deployer.address)).to.be.revertedWith(
        'Key not found',
      )
    })
  })

  describe('Erase', async () => {
    it('Should erase key value pair', async () => {
      const [deployer] = await ethers.getSigners()
      const mappingProxy = new MappingProxy__factory(deployer).attach(
        contractAddress,
      )

      await mappingProxy.insert(deployer.address, 100)
      await expect(mappingProxy.erase(deployer.address)).to.emit(
        mappingProxy,
        'Erased',
      )
      await expect(mappingProxy.get(deployer.address)).to.be.revertedWith(
        'Key not found',
      )
    })

    it('Should do nothing if key does not exist', async () => {
      const [deployer] = await ethers.getSigners()
      const mappingProxy = new MappingProxy__factory(deployer).attach(
        contractAddress,
      )

      await expect(mappingProxy.erase(deployer.address)).to.emit(
        mappingProxy,
        'NotErased',
      )
    })
  })
})
