const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DatabaseModule", (m) => {
    const database = m.contract("Database");

    return { database };
});
