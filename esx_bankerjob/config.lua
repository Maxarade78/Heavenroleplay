Config                      = {}
Config.DrawDistance         = 100.0
Config.BankSavingPercentage = 3
Config.Locale               = 'fr'
Config.MaxInService         = -1
Config.NPCJobEarnings       = {min = 3250, max = 3750}
Config.Interval         = 60 * 60000
Config.Intervalpret         = 180 * 60000

Config.AuthorizedVehicles = {
    { name = 'Stockade',  label = 'Tranporteur de fond' },
}

Config.JobLocations = {
  {x = 308.406, y = 262.778, z = 105.063},
  {x = 134.55, y = -1051.431, z = 29.154},
  {x = 1183.821, y = 2726.268, z = 38.004},
}  

Config.JobLocations1 = {
  {x = -2944.92, y = 478.387, z = 15.257},
}  

Config.Zones = {

  BankActions = {
    Pos   = { x = 260.130, y = 204.308, z = 109.287 },
    Size  = { x = 1.5, y = 1.5, z = 1.0 },
    Color = { r = 102, g = 102, b = 204 },
    Type  = 1
  },
  
  Vehicles = {
        Pos          = { x = 255.478, y = 225.767, z = 101.876 },
        SpawnPoint   = { x = 244.147, y = 193.67, z = 105.028 },
        Size         = { x = 1.8, y = 1.8, z = 1.0 },
        Color        = { r = 255, g = 255, b = 0 },
        Type         = 23,
        Heading      = 64.554,
    },

    VehicleDeleters = {
        Pos   = { x = 254.17, y = 190.067, z = 104.848 },
        Size  = { x = 3.0, y = 3.0, z = 0.2 },
        Color = { r = 255, g = 255, b = 0 },
        Type  = 1,
    }

}
