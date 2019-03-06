/////////////////////////////////////////////////////////////////////////
//  Name: Led_RGB
//  Purpose: Remote RGB led control by means of API REST
//
//  Author:  Javier Bonilla
//  Version: 1.0
//  Date:    08/02/2019
//
//  Copyright 2019 - Mechatronics Blog - https://www.mechatronicsblog.com
//
//  More info and tutorial: https://www.mechatronicsblog.com
/////////////////////////////////////////////////////////////////////////

import QtQuick 2.11
import Felgo 3.0

App {
    id: app

    readonly property string key_r_led: "led_r"
    readonly property string key_g_led: "led_g"
    readonly property string key_b_led: "led_b"
    readonly property string res_state: "state"

    onInitTheme: {
        Theme.colors.tintColor = "#1e73be"
        Theme.navigationBar.backgroundColor = Theme.colors.tintColor
        Theme.navigationBar.titleColor = "white"
        Theme.navigationBar.itemColor  = "white"
    }

    NavigationStack {

        ConfDialog{
            id: confDialog
            onIpChanged: message.text = ""
        }

        Page {
            id: page
            title: qsTr("NodeMCU - RGB Led Control")

            rightBarItem:  NavigationBarRow {
                IconButtonBarItem {
                    icon: IconType.gear
                    onClicked: confDialog.open()
                    title: "Configuration"
                }
            }

            Image{
                anchors.fill: parent
                source: "../assets/MTB_background.jpg"
                fillMode: Image.PreserveAspectCrop
                opacity: 0.5
            }

            Column{
                id: column
                width: page.width
                spacing: dp(5)
                topPadding: dp(10)
                bottomPadding: dp(30)

                Image{
                    source: "../assets/MTB_logo.png"
                    fillMode: Image.PreserveAspectFit
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - dp(40)
                }

                Item{height: dp(5); width: 1}

                AppText{
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Led color"
                    color: "black"
                    font.bold: true
                }

                AppText{
                    property int r: Math.round(rColor.color.r*255);
                    property int g: Math.round(rColor.color.g*255);
                    property int b: Math.round(rColor.color.b*255);

                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: sp(12)
                    text: "(" + r + "," + g + "," + b + ")" + "  #" + decToHex(r) + decToHex(g) + decToHex(b)

                }

                Rectangle{
                    id: rColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: dp(100)
                    width: height
                    color: Qt.rgba(sRed.value/255,sGreen.value/255,sBlue.value/255)
                    border.width: 2
                    border.color: "black"
                }

                Item{height: dp(5); width: 1}

                AppText{
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Red"
                    color: "red"
                    font.bold: true
                }

                AppSlider{
                    id: sRed
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 2*dp(50)
                    tintedTrackColor: "red"
                    from: 0
                    to: 255
                    stepSize: 1
                    onValueChanged: processValueChanged(confDialog.ip,key_r_led,value)
                }

                AppText{
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Green"
                    color: "green"
                    font.bold: true
                }

                AppSlider{
                    id: sGreen
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 2*dp(50)
                    tintedTrackColor: "green"
                    from: 0
                    to: 255
                    stepSize: 1
                    onValueChanged: processValueChanged(confDialog.ip,key_g_led,value)
                }

                AppText{
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Blue"
                    color: "blue"
                    font.bold: true
                }

                AppSlider{
                    id: sBlue
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 2*dp(50)
                    tintedTrackColor: "blue"
                    from: 0
                    to: 255
                    stepSize: 1
                    onValueChanged: processValueChanged(confDialog.ip,key_b_led,value)
                }

                AppText{
                    anchors.horizontalCenter: parent.horizontalCenter
                    id: message
                }

                AppActivityIndicator{
                    id: indicator
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.tintColor
                    animating: false
                    visible: false
                }
            }
        }
    }

    function processValueChanged(ipaddress,led,value)
    {
        if (!confDialog.validateIPaddress(ipaddress))
        {
            message.color = "red"
            message.text  = "Please, introduce a valid IP address"
            sRed.value    = 0
            sGreen.value  = 0
            sBlue.value   = 0
        }
        else request_LED(ipaddress,led,value)
    }

    function request_LED(ip,led,value)
    {
        const port        = 2390
        const request_ON  = "1"
        const request_OFF = "0"
        const led_uri     = "/" + led
        const Http_OK     = 200
        const timeout_ms  = 5000

        var url    = "http://" + ip + ":" + port + led_uri
        var params = "value="+value

        message.text = ""
        indicator.visible = true
        indicator.startAnimating()

        HttpRequest
          .get(url + "?" + params)
          .timeout(timeout_ms)
          .then(function(res)
          {
            if (res.status === Http_OK)
                if (requestSuccess(res.body)) return
            requestError()
          })
          .catch(function(err)
          {
            requestError()
          });
    }

    function requestSuccess(res_json)
    {
        message.color = "black"
        message.text = res_json[res_state]
        indicator.stopAnimating()
        indicator.visible = false
        return true
    }

    function requestError()
    {
        message.color = "red"
        message.text  = qsTr("Connection error")
        indicator.stopAnimating()
        indicator.visible = false
    }


    function decToHex(value)
    {
        var hexString = value.toString(16).toUpperCase();
        if (hexString.length % 2) hexString = '0' + hexString;
        return hexString
    }
}
