package laya.d3.core {
	import laya.d3.core.material.BaseMaterial;
	import laya.d3.core.material.BlinnPhongMaterial;
	import laya.d3.core.render.BaseRender;
	import laya.d3.core.render.RenderContext3D;
	import laya.d3.core.render.RenderElement;
	import laya.d3.core.render.SubMeshRenderElement;
	import laya.d3.graphics.FrustumCulling;
	import laya.d3.graphics.MeshRenderStaticBatchManager;
	import laya.d3.math.BoundBox;
	import laya.d3.math.BoundFrustum;
	import laya.d3.math.BoundSphere;
	import laya.d3.math.ContainmentType;
	import laya.d3.math.Matrix4x4;
	import laya.d3.math.Vector3;
	import laya.d3.resource.models.Mesh;
	import laya.renders.Render;
	
	/**
	 * <code>MeshRenderer</code> 类用于网格渲染器。
	 */
	public class MeshRenderer extends BaseRender {
		/**@private */
		private static var _tempVector30:Vector3 = new Vector3();
		/**@private */
		private static var _tempVector31:Vector3 = new Vector3();
		
		/** @private */
		protected var _projectionViewWorldMatrix:Matrix4x4;
		
		/**
		 * 创建一个新的 <code>MeshRender</code> 实例。
		 */
		public function MeshRenderer(owner:RenderableSprite3D) {
			/*[DISABLE-ADD-VARIABLE-DEFAULT-VALUE]*/
			super(owner);
			_projectionViewWorldMatrix = new Matrix4x4();
		}
		
		/**
		 * @private
		 */
		public function _onMeshChange(mesh:Mesh):void {
			_boundingSphereNeedChange = true;
			_boundingBoxNeedChange = true;
			_boundingBoxCenterNeedChange = true;
		}
		
		/**
		 * @private
		 */
		protected function _calculateBoundingSphereByInitSphere(boundSphere:BoundSphere):void {
			var maxScale:Number;
			var transform:Transform3D = _owner.transform;
			var scale:Vector3 = transform.scale;
			var scaleX:Number = scale.x;
			scaleX || (scaleX = -scaleX);
			var scaleY:Number = scale.y;
			scaleY || (scaleY = -scaleY);
			var scaleZ:Number = scale.z;
			scaleZ || (scaleZ = -scaleZ);
			
			if (scaleX >= scaleY && scaleX >= scaleZ)
				maxScale = scaleX;
			else
				maxScale = scaleY >= scaleZ ? scaleY : scaleZ;
			Vector3.transformCoordinate(boundSphere.center, transform.worldMatrix, _boundingSphere.center);
			_boundingSphere.radius = boundSphere.radius * maxScale;
			
			if (Render.supportWebGLPlusCulling) {//[NATIVE]
				var center:Vector3 = _boundingSphere.center;
				var buffer:Float32Array = FrustumCulling._cullingBuffer;
				buffer[_cullingBufferIndex + 1] = center.x;
				buffer[_cullingBufferIndex + 2] = center.y;
				buffer[_cullingBufferIndex + 3] = center.z;
				buffer[_cullingBufferIndex + 4] = _boundingSphere.radius;
			}
		}
		
		/**
		 * @private
		 */
		protected function _calculateBoundBoxByInitCorners(localBound:BoundBox):void {
			var worldMat:Matrix4x4 = (_owner as MeshSprite3D).transform.worldMatrix;
			localBound.tranform(worldMat, _boundingBox);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function _calculateBoundingSphere():void {
			var sharedMesh:Mesh = (_owner as MeshSprite3D).meshFilter.sharedMesh;
			if (sharedMesh == null || sharedMesh.boundingSphere == null)
				_boundingSphere.toDefault();
			else
				_calculateBoundingSphereByInitSphere(sharedMesh.boundingSphere);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function _calculateBoundingBox():void {
			var sharedMesh:Mesh = (_owner as MeshSprite3D).meshFilter.sharedMesh;
			if (sharedMesh == null || sharedMesh.boundingBox == null)
				_boundingBox.toDefault();
			else
				_calculateBoundBoxByInitCorners(sharedMesh.boundingBox);
		}
		
		/**
		 * @private
		 */
		public function _changeRenderObjectsByMesh(mesh:Mesh):void {
			var count:int = mesh.subMeshCount;
			_renderElements.length = count;
			for (var i:int = 0; i < count; i++) {
				var renderElement:RenderElement = _renderElements[i];
				if (!renderElement) {
					var material:BaseMaterial = sharedMaterials[i];
					renderElement = _renderElements[i] = new SubMeshRenderElement();
					renderElement.setTransform(_owner._transform);
					renderElement.render = this;
					renderElement.material = material ? material : BlinnPhongMaterial.defaultMaterial;//确保有材质,由默认材质代替。
				}
				renderElement.setGeometry(mesh._getSubMesh(i));
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function _needRender(boundFrustum:BoundFrustum):Boolean {
			if (boundFrustum)
				//return boundFrustum.containsBoundSphere(boundingSphere) !== ContainmentType.Disjoint;
				return boundFrustum.containsBoundBox(boundingBox) !== ContainmentType.Disjoint;
			else
				return true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function _renderUpdate(context:RenderContext3D, transform:Transform3D):void {
			if (transform)
				_shaderValues.setMatrix4x4(Sprite3D.WORLDMATRIX, transform.worldMatrix);
			else
				_shaderValues.setMatrix4x4(Sprite3D.WORLDMATRIX, Matrix4x4.DEFAULT);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function _renderUpdateWithCamera(context:RenderContext3D, transform:Transform3D):void {
			var projectionView:Matrix4x4 = context.projectionViewMatrix;
			if (transform) {
				Matrix4x4.multiply(projectionView, transform.worldMatrix, _projectionViewWorldMatrix);
				_shaderValues.setMatrix4x4(Sprite3D.MVPMATRIX, _projectionViewWorldMatrix);
			} else {
				_shaderValues.setMatrix4x4(Sprite3D.MVPMATRIX, projectionView);
			}
			if (Laya3D.debugMode)
				_renderRenderableBoundBox();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function _destroy():void {
			(_isPartOfStaticBatch) && (MeshRenderStaticBatchManager.instance._destroyRenderSprite(_owner));
			super._destroy();
		}
	}

}