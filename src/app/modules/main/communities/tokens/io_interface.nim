import ../../../../../app_service/service/community_tokens/service
import ../../../shared_models/currency_amount

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method airdropCollectibles*(self: AccessInterface, communityId: string, collectiblesJsonString: string, walletsJsonString: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method deployCollectible*(self: AccessInterface, communityId: string, address: string, name: string, symbol: string, description: string, supply: int, infiniteSupply: bool, transferable: bool,
                      selfDestruct: bool, chainId: int, image: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method resetTempValues*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method computeDeployFee*(self: AccessInterface, chainId: int, accountAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onDeployFeeComputed*(self: AccessInterface, ethCurrency: CurrencyAmount, fiatCurrency: CurrencyAmount, errorCode: ComputeFeeErrorCode) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenDeployStateChanged*(self: AccessInterface, communityId: string, chainId: int, transactionHash: string, deployState: DeployState) {.base.} =
  raise newException(ValueError, "No implementation available")