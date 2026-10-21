// ==========================================
// ARSENAL (ARMAS)
// ==========================================

class Espada {
    var property multiplicador = 1

    method poderOtorgado(unGuerrero) = multiplicador * unGuerrero.valorOrigen()
}

class Daga inherits Espada {
    override method poderOtorgado(unGuerrero) = super(unGuerrero) / 2
}

class Baculo {
    var property poder = 400

    method poderOtorgado(unGuerrero) = poder
}

class Hacha {
    var property largoMango = 50
    var property pesoHoja = 5

    method poderOtorgado(unGuerrero) = largoMango * pesoHoja
}

// ==========================================
// GUERREROS
// ==========================================

class Guerrero {
    var property vidaActual = 100
    var property armas = []
    var property elementos = []

    method vida() = vidaActual

    method cantidadDeArmas() = armas.size()

    method estaArmado() = !armas.isEmpty()

    method sumatoriaPoderArmas() = armas.sum({ arma => arma.poderOtorgado(self) })

    method cantidadDeElementos() = elementos.size()

    method cantidadDeElemento(nombreElemento) =
        elementos.count({ elemento => elemento == nombreElemento })

    method agregarArma(unArma) {
        armas.add(unArma)
    }

    method agregarElemento(unElemento) {
        elementos.add(unElemento)
    }

    method perderVida(cantidad) {
        vidaActual = 0.max(vidaActual - cantidad)
    }

    method ganarVida(cantidad) {
        vidaActual += cantidad
    }

    // Por defecto ("Cualquier otro"): 10 veces la cantidad de armas que lleve
    method valorOrigen() = 10 * self.cantidadDeArmas()

    method poder()

    // Polimorfismo con Grupo para recorrer zonas, caminos y regiones
    method todosCumplen(condicion) = condicion.apply(self)

    method algunoCumple(condicion) = condicion.apply(self)

    method aplicarConsecuencia(accion) {
        accion.apply(self)
    }

    method puedeAtravesar(unDestino) = unDestino.puedePasar(self)

    method atravesar(unDestino) {
        unDestino.atravesar(self)
    }
}

class Hobbit inherits Guerrero {
    override method poder() =
        vidaActual + self.cantidadDeElementos() * self.sumatoriaPoderArmas()
}

class Enano inherits Guerrero {
    var property factorDePoder = 1

    override method valorOrigen() = 20

    override method poder() =
        vidaActual + factorDePoder * self.sumatoriaPoderArmas()
}

object elfo {
    var property destrezaBase = 2
}

class Elfo inherits Guerrero {
    var property destrezaPropia = 1

    override method valorOrigen() = 25

    method destrezaBase() = elfo.destrezaBase()

    method destrezaBase(nuevoValor) {
        elfo.destrezaBase(nuevoValor)
    }

    method ganarDestreza(cantidad) {
        destrezaPropia += cantidad
    }

    override method poder() =
        vidaActual + (self.destrezaBase() + destrezaPropia) * self.sumatoriaPoderArmas()
}

class Humano inherits Guerrero {
    var property limitadorDePoder = 1

    override method valorOrigen() = 15

    override method poder() =
        vidaActual + self.sumatoriaPoderArmas() / limitadorDePoder
}

class Maiar inherits Guerrero {
    var property factorBasico = 15
    var property factorBajoAmenaza = 300

    method tienePocaVida() = vidaActual < 10

    method factorActual() =
        if (self.tienePocaVida()) factorBajoAmenaza else factorBasico

    override method poder() =
        vidaActual * self.factorActual() + 2 * self.sumatoriaPoderArmas()
}

object gollum inherits Hobbit {
    override method poder() = super() / 2
}

object tomBombadil inherits Guerrero {
    override method poder() = 10000000

    override method cantidadDeArmas() = 100

    override method estaArmado() = true

    override method perderVida(cantidad) { }
}

// ==========================================
// GRUPOS DE GUERREROS
// ==========================================

class Grupo {
    var property guerreros = []

    method agregarGuerrero(unGuerrero) {
        guerreros.add(unGuerrero)
    }

    method todosCumplen(condicion) = guerreros.all(condicion)

    method algunoCumple(condicion) = guerreros.any(condicion)

    method aplicarConsecuencia(accion) {
        guerreros.forEach(accion)
    }

    method cantidadDeElemento(nombreElemento) =
        guerreros.sum({ guerrero => guerrero.cantidadDeElemento(nombreElemento) })

    method puedeAtravesar(unDestino) = unDestino.puedePasar(self)

    method atravesar(unDestino) {
        unDestino.atravesar(self)
    }
}

// ==========================================
// REQUERIMIENTOS DE ZONA
// ==========================================

object sinRequerimiento {
    method cumple(alguien) = true
}

class RequerimientoDeElemento {
    var property cantidad = 1
    var property elemento = "Lembas"

    method cumple(alguien) = alguien.cantidadDeElemento(elemento) >= cantidad
}

class RequerimientoDeGuerrero {
    var property condicion = { guerrero => true }

    method cumple(alguien) =
        alguien.algunoCumple({ guerrero => self.cumpleGuerrero(guerrero) })

    method cumpleGuerrero(unGuerrero) = condicion.apply(unGuerrero)
}

class RequerimientoMasDeArmas inherits RequerimientoDeGuerrero {
    var property cantidadMinima = 2

    override method cumpleGuerrero(unGuerrero) =
        unGuerrero.cantidadDeArmas() > cantidadMinima
}

class RequerimientoMasDePoder inherits RequerimientoDeGuerrero {
    var property poderMinimo = 1000

    override method cumpleGuerrero(unGuerrero) =
        unGuerrero.poder() > poderMinimo
}

class RequerimientoMasDeVida inherits RequerimientoDeGuerrero {
    var property vidaMinima = 50

    override method cumpleGuerrero(unGuerrero) =
        unGuerrero.vida() > vidaMinima
}

// ==========================================
// ZONAS, CAMINOS Y REGIONES
// ==========================================

class Zona {
    var property requerimiento = sinRequerimiento

    method puedePasar(alguien) =
        alguien.todosCumplen({ guerrero => self.puedePasarGuerrero(guerrero) }) &&
        requerimiento.cumple(alguien)

    method puedePasarGuerrero(unGuerrero) = true

    method consecuencia(alguien) {
        alguien.aplicarConsecuencia({ guerrero => self.consecuenciaGuerrero(guerrero) })
    }

    method consecuenciaGuerrero(unGuerrero) { }

    method validarPasar(alguien) {
        if (!self.puedePasar(alguien)) {
            self.error("No se cumplen las condiciones para atravesar la zona")
        }
    }

    method atravesar(alguien) {
        self.validarPasar(alguien)
        self.consecuencia(alguien)
    }
}

class ZonaDePoder inherits Zona {
    var property poderMinimo = 1500

    override method puedePasarGuerrero(unGuerrero) = unGuerrero.poder() > poderMinimo
}

class ZonaArmada inherits Zona {
    var property vidaPerdida = 10

    override method puedePasarGuerrero(unGuerrero) = unGuerrero.estaArmado()

    override method consecuenciaGuerrero(unGuerrero) {
        unGuerrero.perderVida(vidaPerdida)
    }
}

object lebennin inherits ZonaDePoder {
}

object minasTirith inherits ZonaArmada {
}

object lossarnach inherits Zona {
    override method consecuenciaGuerrero(unGuerrero) {
        unGuerrero.ganarVida(unGuerrero.cantidadDeArmas() * 2)
    }
}

class Camino {
    var property zonas = [lebennin, minasTirith]

    method recorrido() = zonas

    method recorrido(nuevasZonas) {
        zonas = nuevasZonas
    }

    method puedePasar(alguien) = zonas.all({ zona => zona.puedePasar(alguien) })

    method puedeRecorrer(alguien) = self.puedePasar(alguien)

    method validarRecorrido(alguien) {
        if (!self.puedePasar(alguien)) {
            self.error("No se cumplen las condiciones para recorrer el camino")
        }
    }

    method consecuencia(alguien) {
        zonas.forEach({ zona => zona.consecuencia(alguien) })
    }

    method atravesar(alguien) {
        self.validarRecorrido(alguien)
        self.consecuencia(alguien)
    }

    method recorrer(alguien) {
        self.atravesar(alguien)
    }
}

object caminoDeGondor inherits Camino {
}

class Region {
    var property zonas = [lossarnach, lebennin, minasTirith]
    var property camino = caminoDeGondor

    method puedePasar(alguien) = camino.puedePasar(alguien)

    method puedeRecorrer(alguien) = camino.puedeRecorrer(alguien)

    method atravesar(alguien) {
        camino.atravesar(alguien)
    }

    method recorrer(alguien) {
        camino.recorrer(alguien)
    }
}

object gondor inherits Region {
}
