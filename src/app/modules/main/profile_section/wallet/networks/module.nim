import Tables, NimQml
import ../io_interface as delegate_interface
import io_interface, view, controller
import ../../../../../core/eventemitter
import ../../../../../../app_service/service/network/service as network_service
import ../../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../../app_service/service/settings/service as settings_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  networkService: networkService.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, networkService, walletAccountService, settingsService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method refreshNetworks*(self: Module) =
  self.view.load(self.controller.getNetworks())

method load*(self: Module) =
  self.controller.init()
  self.view.setAreTestNetworksEnabled(self.controller.areTestNetworksEnabled())
  self.refreshNetworks()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  self.moduleLoaded = true
  self.delegate.networksModuleDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method areTestNetworksEnabled*(self: Module): bool = 
  return self.controller.areTestNetworksEnabled()

method toggleTestNetworksEnabled*(self: Module) = 
  self.controller.toggleTestNetworksEnabled()
  self.refreshNetworks()