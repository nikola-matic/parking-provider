import chai from 'chai'
import { expect } from 'chai'
import { ethers, network } from 'hardhat'
import { solidity } from 'ethereum-waffle'
import { ParkingSpot__factory } from '../typechain'

chai.use(solidity)

describe('ParkingSpot', function () {
  let contractAddress: string

  beforeEach(async () => {
    const [deployer] = await ethers.getSigners()
    const parkingSpotFactory = new ParkingSpot__factory(deployer)
    const parkingSpotContract = await parkingSpotFactory.deploy()
    contractAddress = parkingSpotContract.address
  })

  describe('Constructor', async () => {
    it('Should have metadata initialized', async () => {
      const [deployer] = await ethers.getSigners()
      const parkingSpot = new ParkingSpot__factory(deployer).attach(
        contractAddress,
      )

      const metaData = await parkingSpot.getMetaData()

      expect(metaData.taken).to.equal(false)
      expect(metaData.acquireTimestamp).to.equal(0)
      expect(metaData.releaseTimestamp).to.equal(0)
      expect(metaData.owner).to.equal(
        '0x0000000000000000000000000000000000000000',
      )
    })
  })

  describe('Acquire spot', async () => {
    it('Should acquire a parking spot', async () => {
      const [deployer, user] = await ethers.getSigners()
      const parkingSpot = new ParkingSpot__factory(deployer).attach(
        contractAddress,
      )

      await parkingSpot.acquire(user.address)
      const metaData = await parkingSpot.getMetaData()

      expect(metaData.taken).to.be.true
      expect(metaData.acquireTimestamp).to.not.equal(0)
      expect(metaData.releaseTimestamp).to.equal(0)
      expect(metaData.owner).to.equal(user.address)
    })
  })

  describe('Release spot', async () => {
    it('Should release a parking spot given same account', async () => {
      const [deployer, user] = await ethers.getSigners()
      const parkingSpot = new ParkingSpot__factory(deployer).attach(
        contractAddress,
      )

      await parkingSpot.acquire(user.address)
      const metaDataAfterAcquire = await parkingSpot.getMetaData()
      const duration = 4000
      const epsilon = 2
      await network.provider.send('evm_increaseTime', [duration])
      await network.provider.send('evm_mine')
      await parkingSpot.release(user.address)
      const metaDataAfterRelease = await parkingSpot.getMetaData()

      expect(
        metaDataAfterRelease.releaseTimestamp
          .sub(metaDataAfterAcquire.acquireTimestamp)
          .toNumber(),
      ).to.be.closeTo(duration, epsilon)
      expect(metaDataAfterRelease.taken).to.be.false
      expect(metaDataAfterRelease.acquireTimestamp).to.equal(0)
      expect(metaDataAfterRelease.owner).to.equal(
        '0x0000000000000000000000000000000000000000',
      )
    })

    it('Should not release a parking spot given different account', async () => {
      const [deployer, user, other] = await ethers.getSigners()
      const parkingSpot = new ParkingSpot__factory(deployer).attach(
        contractAddress,
      )

      await parkingSpot.acquire(user.address)
      await expect(parkingSpot.release(other.address)).to.be.revertedWith(
        'Only owner may release',
      )
    })
  })
})
