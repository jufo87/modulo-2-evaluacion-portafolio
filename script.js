


$(document).ready(function() {
    
   
    $('.navbar-nav a').click(function(e) {
        var target = $(this).attr('href');
        if (target.startsWith('#')) {
            e.preventDefault();
            $('html, body').animate({
                scrollTop: $(target).offset().top - 70
            }, 800);
            
          
            $('.navbar-collapse').collapse('hide');
        }
    });

 

  
    $('#boton-contactar').click(function() {
        $('html, body').animate({
            scrollTop: $('#contacto').offset().top - 70
        }, 800);
    });

   
    $('#solicitar-demo').click(function() {
        $('html, body').animate({
            scrollTop: $('#contacto').offset().top - 70
        }, 800);
        $('#mensaje-contacto').val('Hola, me interesa solicitar una demo gratuita para mi condominio.');
    });

   
    $('#formulario-contacto').submit(function(e) {
        e.preventDefault();
        
        var nombre = $('#nombre-contacto').val();
        var email = $('#email-contacto').val();
        var telefono = $('#telefono-contacto').val();
        var condominio = $('#condominio-contacto').val();
        var mensaje = $('#mensaje-contacto').val();
        
       
        if (!nombre || !email) {
            mostrarAlerta('Error', 'Por favor completa todos los campos requeridos.', 'error');
            return;
        }
        
   
        if (!validarEmail(email)) {
            mostrarAlerta('Error', 'Por favor ingresa un email válido.', 'error');
            return;
        }
        
     
        $('#formulario-contacto button[type="submit"]').prop('disabled', true).html('<i class="bi bi-hourglass-split"></i> Enviando...');
        
        setTimeout(function() {
            mostrarAlerta('¡Éxito!', '¡Gracias por tu interés! Te contactaremos pronto.', 'success');
            $('#formulario-contacto')[0].reset();
            $('#formulario-contacto button[type="submit"]').prop('disabled', false).html('<i class="bi bi-send"></i> Enviar Mensaje');
        }, 2000);
    });

  
    $(window).scroll(function() {
        var scrollTop = $(window).scrollTop();
        var windowHeight = $(window).height();
        
        $('.tarjeta-funcion, .beneficio-item').each(function() {
            var elementTop = $(this).offset().top;
            if (scrollTop + windowHeight > elementTop + 50) {
                $(this).addClass('animate-fade-in');
            }
        });
        
      
        if (scrollTop > 50) {
            $('.navbar').addClass('navbar-scrolled');
        } else {
            $('.navbar').removeClass('navbar-scrolled');
        }
    });

  
    $('.tarjeta-funcion').hover(
        function() {
            $(this).find('.icono-funcion').animate({
                fontSize: '3.5rem'
            }, 200);
        },
        function() {
            $(this).find('.icono-funcion').animate({
                fontSize: '3rem'
            }, 200);
        }
    );

  
    function contadorAnimado(elemento, valorFinal, duracion) {
        var valorInicial = 0;
        var incremento = valorFinal / (duracion / 16);
        
        function actualizar() {
            valorInicial += incremento;
            if (valorInicial >= valorFinal) {
                valorInicial = valorFinal;
                clearInterval(intervalo);
            }
            $(elemento).text(Math.floor(valorInicial));
        }
        
        var intervalo = setInterval(actualizar, 16);
    }

  
    $('[data-bs-toggle="tooltip"]').tooltip();

   
    function mostrarAlerta(titulo, mensaje, tipo) {
        var iconos = {
            'success': 'bi-check-circle',
            'error': 'bi-exclamation-triangle',
            'info': 'bi-info-circle'
        };
        
        var colores = {
            'success': 'alert-success',
            'error': 'alert-danger',
            'info': 'alert-info'
        };
        
        var alerta = `
            <div class="alert ${colores[tipo]} alert-dismissible fade show position-fixed" 
                 style="top: 100px; right: 20px; z-index: 9999; min-width: 300px;" role="alert">
                <i class="bi ${iconos[tipo]} me-2"></i>
                <strong>${titulo}</strong> ${mensaje}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        `;
        
        $('body').append(alerta);
        
      
        setTimeout(function() {
            $('.alert').fadeOut();
        }, 5000);
    }

  
    function validarEmail(email) {
        var regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return regex.test(email);
    }

    
    function efectoEscritura(elemento, texto, velocidad) {
        var i = 0;
        var timer = setInterval(function() {
            if (i < texto.length) {
                $(elemento).append(texto.charAt(i));
                i++;
            } else {
                clearInterval(timer);
            }
        }, velocidad);
    }

   
    function lazyLoad() {
        $('img[data-src]').each(function() {
            var img = $(this);
            var src = img.attr('data-src');
            
            if ($(window).scrollTop() + $(window).height() > img.offset().top) {
                img.attr('src', src);
                img.removeAttr('data-src');
            }
        });
    }

  
    $(window).scroll(lazyLoad);

  
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

   
    $('a[href*="#"]').not('[href="#"]').not('[href="#0"]').click(function(event) {
        if (location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '') && 
            location.hostname == this.hostname) {
            var target = $(this.hash);
            target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
            if (target.length) {
                event.preventDefault();
                $('html, body').animate({
                    scrollTop: target.offset().top - 70
                }, 1000);
            }
        }
    });

   
    setTimeout(function() {
        console.log('¡Bienvenido a Sin Nombre! 🏢');
        console.log('Sistema de control de acceso para condominios');
    }, 1000);

  
    window.condoAccess = {
        
        cambiarTema: function(tema) {
            $('body').removeClass('tema-claro tema-oscuro').addClass('tema-' + tema);
        },
        
    
        mostrarEstadisticas: function() {
            console.log('Estadísticas del sistema Sin Nombre');
        },
        
      
        configurarDemo: function() {
            mostrarAlerta('Demo', 'Configurando demo del sistema...', 'info');
        }
    };

});