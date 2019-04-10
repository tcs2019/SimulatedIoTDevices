App = {
    web3Provider: null,
    contracts: {},
    account: 0x0,
    loading: false,


    init: function() {
        return App.initWeb3();
    },

    initWeb3: function() {
        // initialize web3
        if (typeof web3 !== 'undefined') {
            //reuse the provider of the Web3 object injected by Metamask
            App.web3Provider = web3.currentProvider;
        } else {
            //create a new provider and plug it directly into our local node
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }
        web3 = new Web3(App.web3Provider);

        App.displayAccountInfo();

        return App.initContract();
    },

    displayAccountInfo: function() {


        web3.eth.getCoinbase(function(err, account) {
            if (err === null) {
                console.log(account);
                App.account = account;
                $('#account').text(account);
                // web3.eth.getBalance(account, function(err, balance) {
                //     if (err === null) {
                //         $('#accountBalance').text(web3.fromWei(balance, "ether") + " ETH");
                //     }
                // })
            }
        });
    },

    initContract: function() {
        $.getJSON('LightBulbs.json', function(ioTDevicesArtifact) {
            // get the contract artifact file and use it to instantiate a truffle contract abstraction
            App.contracts.IoTDevices = TruffleContract(ioTDevicesArtifact);
            // set the provider for our contracts
            App.contracts.IoTDevices.setProvider(App.web3Provider);
            // listen to events
            App.listenToEvents();
            // retrieve the device from the contract
            return App.reloadDevicesList();
        });
    },

    reloadDevicesList: function() {
        // avoid reentry
        if (App.loading) {
            return;
        }
        App.loading = true;

        // refresh account information because the balance might have changed
        App.displayAccountInfo();

        var ioTDevicesInstance;

        App.contracts.IoTDevices.deployed().then(function(instance) {
            ioTDevicesInstance = instance;
            return ioTDevicesInstance.getNumberOfdevices();
        }).then(function(deviceIds) {
            // retrieve the device placeholder and clear it
            $('#devicesRow').empty();
            console.log("Displaying devices");

            for (var i = 0; i < deviceIds; i++) {
                console.log(deviceIds);
                ioTDevicesInstance.lightBulbs(i).then(function(device) {
                    App.displayDevice(device[0], device[1], device[2]);
                    console.log(device[0]);
                });
            }
            App.loading = false;
        }).catch(function(err) {
            console.error(err.message);
            App.loading = false;
        });
    },

    displayDevice: function(id, name, description) {
        var devicesRow = $('#devicesRow');
        // var deviceid = $('#deviceid');

        var deviceTemplate = $("#deviceTemplate");
        deviceTemplate.find('.panel-title').text(name);
        deviceTemplate.find('.device-description').text(description);
        deviceTemplate.find('.device-deviceid').text(id);

        // seller
        // if (seller == App.account) {
        //     deviceTemplate.find('.device-seller').text("You");
        //     deviceTemplate.find('.btn-buy').hide();
        // } else {
        //     deviceTemplate.find('.device-seller').text(seller);
        //     deviceTemplate.find('.btn-buy').show();
        // }

        // add this new device
        devicesRow.append(deviceTemplate.html());
    },

    addDevice: function() {
        // retrieve the detail of the device
        var _device_name = $('#device_name').val();
        var _description = $('#device_description').val();

        if ((_device_name.trim() == '')) {
            // nothing to sell
            return false;
        }

        App.contracts.IoTDevices.deployed().then(function(instance) {
            console.log(_device_name);
            return instance._addNewLightBulb(_device_name, _description, {
                from: App.account,
                gas: 500000
            });
        }).then(function(result) {

        }).catch(function(err) {
            console.error(err);
        });
    },

    // listen to events triggered by the contract
    listenToEvents: function() {
        App.contracts.IoTDevices.deployed().then(function(instance) {
            instance.NewLightBulb({}, {}).watch(function(error, event) {
                if (!error) {
                    $("#events").append('<li class="list-group-item">' + event.args._name + ' (' + event.args._description + ' )' + ' is now added</li>');
                } else {
                    console.error(error);
                }
                App.reloadDevicesList();
            });
        });
    },
};

$(function() {
    $(window).load(function() {
        App.init();
    });
});