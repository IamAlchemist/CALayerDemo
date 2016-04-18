//
//  CAEAGLLayerViewController.swift
//  CALayerDemo
//
//  Created by wizard on 4/18/16.
//  Copyright © 2016 Alchemist. All rights reserved.
//

import UIKit
import GLKit

class CAEAGLLayerViewController : UIViewController {
    var frameBuffer : GLuint = 0
    var colorRenderbuffer : GLuint = 0
    var frameBufferWidth : GLint = 0
    var frameBufferHeight : GLint = 0
    var effect = GLKBaseEffect()
    var glContext = EAGLContext(API: .OpenGLES2)
    var glLayer = CAEAGLLayer()
    
    
    func setupBuffers() {
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        
        glGenRenderbuffers(1, &colorRenderbuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderbuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderbuffer)
        glContext.renderbufferStorage(Int(GL_RENDERBUFFER), fromDrawable: glLayer)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_WIDTH), &frameBufferWidth)
        glGetRenderbufferParameteriv(GLenum(GL_RENDERBUFFER), GLenum(GL_RENDERBUFFER_HEIGHT), &frameBufferHeight)
        
        if glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER)) != GLenum(GL_FRAMEBUFFER_COMPLETE) {
            assertionFailure("fail to complete framebuffer")
        }
    }
    
    func tearDownBuffers() {
        if frameBuffer != 0 {
            glDeleteFramebuffers(1, &frameBuffer)
            frameBuffer = 0
        }
        
        if colorRenderbuffer != 0 {
            glDeleteRenderbuffers(1, &colorRenderbuffer)
            colorRenderbuffer = 0
        }
    }
    
    func drawFrame() {
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glViewport(0, 0, frameBufferWidth, frameBufferHeight)
        
        effect.prepareToDraw()
        
        //clear the screen
        glClear(GLenum(GL_COLOR_BUFFER_BIT))
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        //set up vertices
        let vertices: [GLfloat] = [
            -0.5, -0.5, -1.0, 0.0, 0.5, -1.0, 0.5, -0.5, -1.0
        ]
        
        //set up colors
        let colors: [GLfloat] = [
            0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0
        ]
        
        //draw triangle
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Position.rawValue))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.Color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, vertices)
        glVertexAttribPointer(GLuint(GLKVertexAttrib.Color.rawValue),4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, colors)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)

        //present render buffer
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderbuffer);
        glContext.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EAGLContext.setCurrentContext(glContext)
        
        glLayer.frame = view.bounds
        view.layer.addSublayer(glLayer)
        glLayer.drawableProperties = [kEAGLDrawablePropertyRetainedBacking: false, kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8]
        
        setupBuffers()
        
        drawFrame()
    }
    
    
    deinit {
        tearDownBuffers()
        EAGLContext.setCurrentContext(nil)
    }
    
    
}
