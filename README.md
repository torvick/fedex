# Fedex

Fedex es una gema de Ruby que te permite cotizar envíos usando la API de Fedex.

## Instalación

Agregue esta línea al Gemfile de su aplicación:

```ruby
gem 'fedex'
```

Y luego ejecutar:

    $ bundle install

O instálelo usted mismo como:

    $ gem install fedex

## Uso

Para usar la gema de Fedex, deberá crear una nueva instancia de la clase Fedex::Client con sus credenciales de FedEx:

```ruby
require 'fedex'

client = Fedex::Client.new('key', 'password', 'account_number', 'meter_number')
```

Una vez que tenga su instancia de cliente, puede usar la clase Fedex::Rates.get(credentials, quote_params) para recuperar las tarifas de envío:

```ruby
quote_params = {
  address_from: {
    zip: "64000",
    country: "MX"
  },
  address_to: {
    zip: "64000",
    country: "MX"
  },
  parcel: {
    length: 25.0,
    width: 28.0,
    height: 46.0,
    distance_unit: "cm",
    weight: 6.5,
    mass_unit: "kg"
  }
}

rates = Fedex::Rates.get(client.credentials, quote_params)

```
El método get toma el argumento, quote_params, que debe ser un hash que contenga la información necesaria para obtener una tarifa de envío. Si falta alguno de los parámetros requeridos, la gema devolverá un mensaje de error en lugar de intentar realizar la solicitud.

## Contribuyendo

Si quieres contribuir a esta gema, por favor sigue estos pasos:

Haz un fork del repositorio
Crea una rama con tus cambios (git checkout -b mi-nueva-funcionalidad)
Haz commit de tus cambios (git commit -am 'Agregué una nueva funcionalidad')
Haz push de tu rama (git push origin mi-nueva-funcionalidad)
Abre un pull request

## Licencia

Esta gema está disponible como código abierto bajo los términos de la Licencia [MIT License](https://opensource.org/licenses/MIT).

## Código de conducta

Se espera que todos los que interactúen en las bases de código, los rastreadores de problemas, las salas de chat y las listas de correo del proyecto Fedex sigan el [code of conduct](https://github.com/[USERNAME]/fedex/blob/master/CODE_OF_CONDUCT.md).