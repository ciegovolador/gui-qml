// Copyright (c) 2024 The Bitcoin Core developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import org.bitcoincore.qt 1.0

import "../../controls"
import "../../controls/utils.js" as Utils
import "../../components"
import "../node"

Page {
    id: root
    background: null

    ButtonGroup { id: navigationTabs }

    header: NavigationBar2 {
        id: navBar
        leftItem: WalletBadge {
            implicitWidth: 154
            implicitHeight: 46
            text: walletListModel.selectedWallet

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    walletListModel.listWalletDir()
                    walletSelect.opened ? walletSelect.close() : walletSelect.open()
                }
            }

            WalletSelect {
                id: walletSelect
                model: walletListModel
                closePolicy: Popup.CloseOnPressOutside
                x: 0
                y: parent.height
            }
        }
        centerItem: RowLayout {
            NavigationTab {
                id: activityTabButton
                checked: true
                text: qsTr("Activity")
                property int index: 0
                ButtonGroup.group: navigationTabs
            }
            NavigationTab {
                text: qsTr("Send")
                property int index: 1
                ButtonGroup.group: navigationTabs
            }
            NavigationTab {
                text: qsTr("Receive")
                property int index: 2
                ButtonGroup.group: navigationTabs
            }
        }
        rightItem: RowLayout {
            spacing: 5
            NetworkIndicator {
                textSize: 11
                Layout.rightMargin: 5
                shorten: true
            }
            NavigationTab {
                id: blockClockTabButton
                Layout.preferredWidth: 30
                Layout.rightMargin: 10
                property int index: 3
                property var syncState: Utils.formatRemainingSyncTime(nodeModel.remainingSyncTime)
                property bool synced: nodeModel.verificationProgress > 0.9999
                property bool paused: nodeModel.pause
                property bool connected: nodeModel.numOutboundPeers > 0
                ButtonGroup.group: navigationTabs  
                property bool estimating: syncState.estimating
                property bool faulted: nodeModel.faulted
                

                BlockClockDial {
                    anchors.horizontalCenter: blockClockTabButton.horizontalCenter
                    scale: Theme.blockclocksize
                    width: blockClockTabButton.width
                    height: width * 2
                    penWidth: width / 20
                    timeRatioList: chainModel.timeRatioList
                    verificationProgress: nodeModel.verificationProgress
                    paused: blockClockTabButton.paused || blockClockTabButton.faulted
                    connected: blockClockTabButton.connected
                    synced: nodeModel.verificationProgress > 0.999
                    backgroundColor: Theme.color.neutral2
                    timeTickColor: Theme.color.neutral5
                    confirmationColors: Theme.color.confirmationColors
                    

                    Behavior on backgroundColor {
                        ColorAnimation { duration: 150 }
                    }

                    Behavior on timeTickColor {
                        ColorAnimation { duration: 150 }
                    }

                    Behavior on confirmationColors {
                        ColorAnimation { duration: 150 }
                    }
                }

    

                Tooltip {
                    id: blockClockTooltip
                    anchors.top: blockClockTabButton.bottom
                    anchors.topMargin: -5
                    anchors.horizontalCenter: blockClockTabButton.horizontalCenter

                    visible: blockClockTabButton.hovered
                    text: {
                        if (blockClockTabButton.paused) {
                            qsTr("Paused")
                        } else if (blockClockTabButton.connected && blockClockTabButton.synced) {
                            qsTr("Blocktime\n" +  Number(nodeModel.blockTipHeight).toLocaleString(Qt.locale(), 'f', 0))
                        } else if (blockClockTabButton.connected){
                            qsTr("Downloading blocks\n" +  syncState.text)
                        } else {
                            qsTr("Connecting")
                        }
                    }
                }
            }
            NavigationTab {
                iconSource: "image://images/gear-outline"
                iconColor: Theme.color.neutral7
                Layout.preferredWidth: 30
                property int index: 4
                ButtonGroup.group: navigationTabs
            }
        }
        background: Rectangle {
            color: Theme.color.neutral4
            anchors.bottom: navBar.bottom
            anchors.bottomMargin: 4
            height: 1
            width: parent.width
        }
    }

    StackLayout {
        width: parent.width
        height: parent.height
        currentIndex: navigationTabs.checkedButton.index
        Item {
            id: activityTab
            CoreText { text: "Activity" }
        }
        Item {
            id: sendTab
            CoreText { text: "Send" }
        }
        Item {
            id: receiveTab
            CoreText { text: "Receive" }
        }
        Item {
            id: blockClockTab
            anchors.fill: parent
            BlockClock {
                parentWidth: parent.width - 40
                parentHeight: parent.height
                anchors.centerIn: parent
                showNetworkIndicator: false
            }
        }
        NodeSettings {
            showDoneButton: false
        }
    }

    Component.onCompleted: nodeModel.startNodeInitializionThread();
}
