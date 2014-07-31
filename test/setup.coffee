chai = require("chai")

chai.should()
global.expect = chai.expect

global.sinon = require("sinon")
global.Factory = require("..")
