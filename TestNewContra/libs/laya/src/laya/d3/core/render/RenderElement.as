package laya.d3.core.render {
	import laya.d3.core.BaseCamera;
	import laya.d3.core.GeometryElement;
	import laya.d3.core.Transform3D;
	import laya.d3.core.material.BaseMaterial;
	import laya.d3.core.material.RenderState;
	import laya.d3.core.scene.Scene3D;
	import laya.d3.shader.Shader3D;
	import laya.d3.shader.ShaderInstance;
	import laya.d3.shader.ShaderPass;
	import laya.d3.shader.SubShader;
	import laya.layagl.LayaGL;
	import laya.utils.Stat;
	import laya.webgl.WebGLContext;
	
	/**
	 * @private
	 * <code>RenderElement</code> 类用于实现渲染元素。
	 */
	public class RenderElement {
		/** @private */
		public var _transform:Transform3D;
		/** @private */
		public var _geometry:GeometryElement;
		
		/** @private */
		public var material:BaseMaterial;
		/** @private */
		public var render:BaseRender;
		/** @private */
		public var staticBatch:GeometryElement;
		
		/**
		 * 创建一个 <code>RenderElement</code> 实例。
		 */
		public function RenderElement() {
		/*[DISABLE-ADD-VARIABLE-DEFAULT-VALUE]*/
		}
		
		/**
		 * @private
		 */
		public function setTransform(transform:Transform3D):void {
			_transform = transform;
		}
		
		/**
		 * @private
		 */
		public function setGeometry(geometry:GeometryElement):void {
			_geometry = geometry;
		}
		
		/**
		 * @private
		 */
		public function addToOpaqueRenderQueue(context:RenderContext3D, queue:RenderQueue):void {
			queue.elements.push(this);
		}
		
		/**
		 * @private
		 */
		public function addToTransparentRenderQueue(context:RenderContext3D, queue:RenderQueue):void {
			queue.elements.push(this);
			queue.lastTransparentBatched = false;
			queue.lastTransparentRenderElement = this;
		}
		
		/**
		 * @private
		 */
		public function _render(context:RenderContext3D, isTarget:Boolean, customShader:Shader3D = null, replacementTag:String = null):void {
			var lastStateRenderState:RenderState, lastStateRender:BaseRender;
			var loopCount:int = Stat.loopCount;
			var scene:Scene3D = context.scene;
			var camera:BaseCamera = context.camera;
			
			var transform:Transform3D = _transform;
			var geometry:GeometryElement = _geometry;
			context.renderElement = this;
			
			if (loopCount !== render._updateLoopCount) {//此处处理更新为裁剪和合并后的，可避免浪费
				render._renderUpdate(context, transform);
				render._renderUpdateWithCamera(context, transform);
				render._updateLoopCount = loopCount;
				render._updateCamera = camera;
			} else if (camera !== render._updateCamera) {
				render._renderUpdateWithCamera(context, transform);
				render._updateCamera = camera;
			}
			
			if (geometry._prepareRender(context)) {
				var subShader:SubShader = material._shader.getSubShaderAt(0);//TODO:
				var renderStates:Vector.<RenderState> = material._renderStates;
				var passes:Vector.<ShaderPass>;
				if (customShader) {
					if (replacementTag) {
						var oriTag:String = subShader.getFlag(replacementTag);
						if (oriTag) {
							var customSubShaders:Vector.<SubShader> = customShader._subShaders;
							for (var k:int = 0, p:int = customSubShaders.length; k < p; k++) {
								var customSubShader:SubShader = customSubShaders[k];
								if (oriTag === customSubShader.getFlag(replacementTag)) {
									passes = customSubShader._passes;
									break;
								}
							}
							if (!passes)
								return;
						} else {
							return;
						}
					} else {
						passes = customShader.getSubShaderAt(0)._passes;//TODO:
					}
				} else {
					passes = subShader._passes;
				}
				
				for (var j:int = 0, m:int = passes.length; j < m; j++) {
					var shaderPass:ShaderInstance = context.shader = passes[j].withCompile((scene._defineDatas.value) & (~material._disablePublicDefineDatas.value), render._defineDatas.value, material._defineDatas.value);
					var switchShader:Boolean = shaderPass.bind();//纹理需要切换shader时重新绑定 其他uniform不需要
					var switchShaderLoop:Boolean = (loopCount !== shaderPass._uploadLoopCount);
					
					var uploadScene:Boolean = (shaderPass._uploadScene !== scene) || switchShaderLoop;
					if (uploadScene || switchShader) {
						shaderPass.uploadUniforms(shaderPass._sceneUniformParamsMap, scene._shaderValues, uploadScene);
						shaderPass._uploadScene = scene;
					}
					
					var switchCamera:Boolean = shaderPass._uploadCamera !== camera;
					var uploadSprite3D:Boolean = (switchCamera || shaderPass._uploadRender !== render) || switchShaderLoop;
					if (uploadSprite3D || switchShader) {
						shaderPass.uploadUniforms(shaderPass._spriteUniformParamsMap, render._shaderValues, uploadSprite3D);
						shaderPass._uploadRender = render;
					}
					
					var uploadCamera:Boolean = switchCamera || switchShaderLoop;
					if (uploadCamera || switchShader) {
						shaderPass.uploadUniforms(shaderPass._cameraUniformParamsMap, camera._shaderValues, uploadCamera);
						shaderPass._uploadCamera = camera;
					}
					
					var uploadMaterial:Boolean = (shaderPass._uploadMaterial !== material) || switchShaderLoop;
					if (uploadMaterial || switchShader) {
						shaderPass.uploadUniforms(shaderPass._materialUniformParamsMap, material._shaderValues, uploadMaterial);
						shaderPass._uploadMaterial = material;
					}
					
					var renderState:RenderState = renderStates[j];
					if (lastStateRenderState !== renderState) {//lastStateMaterial,lastStateOwner存到全局，多摄像机还可优化
						renderState._setRenderStateBlendDepth();
						renderState._setRenderStateFrontFace(isTarget, transform);
						lastStateRenderState = renderState;
						lastStateRender = render;
					} else {
						if (lastStateRender !== render) {//TODO:是否可以用transfrom
							renderState._setRenderStateFrontFace(isTarget, transform);
							lastStateRender = render;
						}
					}
					if (customShader)	//TODO:临时
						WebGLContext.setBlend(LayaGL.instance, false);
					
					geometry._render(context);
					shaderPass._uploadLoopCount = loopCount;
				}
			}
		}
		
		/**
		 * @private
		 */
		public function destroy():void {
			_transform = null;
			_geometry = null;
			material = null;
			render = null;
		}
	}
}