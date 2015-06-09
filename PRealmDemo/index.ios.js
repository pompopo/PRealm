/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */
'use strict';

var React = require('react-native');
var {
  AppRegistry,
  StyleSheet,
  Text,
  View,
} = React;

var PRealm = require('NativeModules').PRealm;

PRealm.defineSchema("Person", {name: "string", age: "int", like: "array Item"});
PRealm.defineSchema("Item", {name: "string"});

var e1 = {name: "Beer"};
var e2 = {name: "Game"};
PRealm.add("Person", {name:"pompopo", age: 28, like: [e1, e2]});
PRealm.find("Person", "age > 26", (e) => {
  console.log(e);
});

var PRealmDemo = React.createClass({
  render: function() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit index.ios.js
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
      </View>
    );
  }
});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('PRealmDemo', () => PRealmDemo);
