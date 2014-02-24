class ErrorCodes
  # http://www.elmelectronics.com/DSheets/ELM327DSH.pdf
  def self.codes
    {
      '0' => ['P0', 'Powertrain Codes - SAE defined'],
      '1' => ['P1', 'Powertrain Codes - manufacturer defined'],
      '2' => ['P2', 'Powertrain Codes - SAE defined'],
      '3' => ['P3', 'Powertrain Codes - jointly defined'],
      '4' => ['C0', 'Chassis Codes - SAE defined'],
      '5' => ['C1', 'Chassis Codes - manufacturer defined'],
      '6' => ['C2', 'Chassis Codes - manufacturer defined'],
      '7' => ['C3', 'Chassis Codes - reserved for future'],
      '8' => ['B0', 'Body Codes - SAE defined'],
      '9' => ['B1', 'Body Codes - manufacturer defined'],
      'A' => ['B2', 'Body Codes - manufacturer defined'],
      'B' => ['B3', 'Body Codes - reserved for future'],
      'C' => ['U0', 'Network Codes - SAE defined'],
      'D' => ['U1', 'Network Codes - manufacturer defined'],
      'E' => ['U2', 'Network Codes - manufacturer defined'],
      'F' => ['U3', 'Network Codes - reserved for future']
    }
  end
end