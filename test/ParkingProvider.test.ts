import chai from 'chai'
import { expect } from 'chai'
import { ethers, network } from 'hardhat'
import { solidity } from 'ethereum-waffle'
import { ParkingProvider__factory } from '../typechain'

chai.use(solidity)

describe('ParkingProvider', async () => {
  let contractAddress: string

  beforeEach(async () => {
    const [deployer] = await ethers.getSigners()
    const parkingProviderFactory = new ParkingProvider__factory(deployer)
    const parkingProviderContract = await parkingProviderFactory.deploy()
    contractAddress = parkingProviderContract.address
  })

  describe('Constructor', async () => {
    it('Should assign roles properly', async () => {
      const [deployer] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )
      const DEFAULT_ADMIN_ROLE =
        '0x0000000000000000000000000000000000000000000000000000000000000000'
      const MINTER_ROLE = ethers.utils.id('MINTER_ROLE')
      const BURNER_ROLE = ethers.utils.id('BURNER_ROLE')

      expect(
        await parkingProvider.hasRole(DEFAULT_ADMIN_ROLE, deployer.address),
      ).to.be.true
      expect(await parkingProvider.hasRole(MINTER_ROLE, deployer.address)).to.be
        .true
      expect(await parkingProvider.hasRole(BURNER_ROLE, deployer.address)).to.be
        .true
    })

    it('Should have no parking spots initially', async () => {
      const [deployer] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )
      const parkingSpots = await parkingProvider.getParkingSpots()

      expect(parkingSpots).to.be.empty
    })

    it('Should have correctly set intial state', async () => {
      const [deployer] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )
      const parkingState = await parkingProvider.getParkingState()

      expect(parkingState.freeSpots).to.equal(0)
      expect(parkingState.occupiedSpots).to.equal(0)
    })
  })

  describe('Create parking spot', async () => {
    it('Should create a spot as minter', async () => {
      const [deployer] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )

      await parkingProvider.createParkingSpot()
      const parkingState = await parkingProvider.getParkingState()
      const parkingSpots = await parkingProvider.getParkingSpots()

      expect(parkingState.freeSpots).to.equal(1)
      expect(parkingState.occupiedSpots).to.equal(0)
      expect(parkingSpots.length).to.equal(1)
    })

    it('Should throw if called by non minter', async () => {
      const [deployer, user] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )

      await expect(
        parkingProvider.connect(user).createParkingSpot(),
      ).to.be.revertedWith('Only minter may create spot')

      const parkingState = await parkingProvider.getParkingState()
      const parkingSpots = await parkingProvider.getParkingSpots()

      expect(parkingState.freeSpots).to.equal(0)
      expect(parkingState.occupiedSpots).to.equal(0)
      expect(parkingSpots.length).to.equal(0)
    })
  })

  describe('Destroy parking spot', async () => {
    it('Should destroy parking spot as burner', async () => {
      const [deployer] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )

      await parkingProvider.createParkingSpot()
      await parkingProvider.destroyParkingSpot()
      const parkingState = await parkingProvider.getParkingState()
      const parkingSpots = await parkingProvider.getParkingSpots()

      expect(parkingState.freeSpots).to.equal(0)
      expect(parkingState.occupiedSpots).to.equal(0)
      expect(parkingSpots.length).to.equal(0)
    })

    it('Should throw if called by non burner', async () => {
      const [deployer, user] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )

      await expect(
        parkingProvider.connect(user).destroyParkingSpot(),
      ).to.be.revertedWith('Only burner may destroy spot')
    })

    it('Should throw if no parking spots exist', async () => {
      const [deployer, user] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )

      await expect(
        parkingProvider.connect(deployer).destroyParkingSpot(),
      ).to.be.revertedWith('No parking spots to remove')
    })

    it('Should throw if all spots are occupied', async () => {
      const [deployer, user] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )

      await parkingProvider.createParkingSpot()
      await parkingProvider.connect(user).acquireSpot()

      await expect(parkingProvider.destroyParkingSpot()).to.be.revertedWith(
        'No unoccupied parking spots',
      )
    })
  })

  describe('Acquire parking spot', async () => {
    it('Should acquire parking spot', async () => {
      const [deployer, user] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )

      await parkingProvider.createParkingSpot()
      await parkingProvider.connect(user).acquireSpot()

      const parkingState = await parkingProvider.getParkingState()

      expect(parkingState.freeSpots).to.equal(0)
      expect(parkingState.occupiedSpots).to.equal(1)
    })

    it('Should throw if no parking spots exist', async () => {
      const [deployer, user] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )

      await expect(
        parkingProvider.connect(user).acquireSpot(),
      ).to.be.revertedWith('No parking spots to acquire')
    })

    it('Should throw if all spots are occupied', async () => {
      const [deployer, user1, user2] = await ethers.getSigners()
      const parkingProvider = new ParkingProvider__factory(deployer).attach(
        contractAddress,
      )

      await parkingProvider.createParkingSpot()
      await parkingProvider.connect(user1).acquireSpot()

      await expect(
        parkingProvider.connect(user2).acquireSpot(),
      ).to.be.revertedWith('No unoccupied parking spots')
    })
  })
})
