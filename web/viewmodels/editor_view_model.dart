
class EditorViewModel extends ViewModelBase
{
  Accordion _componentArea;
  TreeView _entityArea;
  WebGLRenderingContext _context;
  final EditorView _view;

  EditorViewModel(this._view)
  {
    // Entity tree-view
    registerEventHandler('entity_area_loaded', _entityAreaLoadedHandler);
    registerEventHandler('entity_selected', _entitySelectedHandler);

    // Component accordion
    registerEventHandler('component_area_loaded', _componentAreaLoadedHandler);

    // File events
    registerEventHandler('new_file_clicked', _newFileHandler);
    registerEventHandler('save_file_clicked', _saveFileHandler);

    // Model events
    registerEventHandler('add_box_clicked', _addBoxHandler);
    registerEventHandler('add_sphere_clicked', _addSphereHandler);
    registerEventHandler('add_plane_clicked', _addPlaneHandler);

    // Canvas events
    registerEventHandler('canvas_loaded', _canvasLoadedHandler);
    registerEventHandler('frame', _frameHandler);

    // Zoidberg
    registerEventHandler('zoidberg', zoidberg);
  }

  /** Initialized the editor to a starting state */
  void _initEditor()
  {
    assert(_entityArea != null);
    assert(_componentArea != null);

    _componentArea.accordionItems.clear();
    _entityArea.children.clear();
  }

  //---------------------------------------------------------------------
  // Entity area handling
  //---------------------------------------------------------------------

  void _entityAreaLoadedHandler(TreeView source, _)
  {
    if (_entityArea != null) return;
    _entityArea = source;

    // TODO (JOHN) need a better way to know when the entire view is loaded
    // instead of knowing the last piece of content that is loaded, which
    // can prove to be unreliable if the template is changed.
    _initEditor();
  }

  void _entitySelectedHandler(_, TreeNodeSelectedEventArgs args)
  {
    _updateEntityUI(args.node.tag);
  }

  //---------------------------------------------------------------------
  // Component area handling
  //---------------------------------------------------------------------

  void _componentAreaLoadedHandler(Accordion source, _)
  {
    if (_componentArea != null) return;
    _componentArea = source;
  }

  //---------------------------------------------------------------------
  // File handling
  //---------------------------------------------------------------------

  void _newFileHandler(_, __)
  {
    _initEditor();
  }

  void _saveFileHandler(_, __)
  {
    print('Saving file');
  }

  //---------------------------------------------------------------------
  // Model handling
  //---------------------------------------------------------------------

  void _addBoxHandler(_, __)
  {
    EntityViewModel entity = new EntityViewModel();
    entity.components.add(new BoxVisualProperties());

    _addEntity(entity, 'Box', 'web/views/templates/box_icon.xml');
  }

  void _addSphereHandler(_, __)
  {
    EntityViewModel entity = new EntityViewModel();
    entity.components.add(new SphereVisualProperties());

    _addEntity(entity, 'Sphere', 'web/views/templates/sphere_icon.xml');
  }

  void _addPlaneHandler(_, __)
  {
    EntityViewModel entity = new EntityViewModel();
    entity.components.add(new PlaneVisualProperties());

    _addEntity(entity, 'Plane', 'web/views/templates/plane_icon.xml');
  }

  void _addEntity(EntityViewModel entity, String treeNodeHeader, String treeNodeIcon)
  {
    Template.deserialize(treeNodeIcon)
      .then((t) {
        TreeNode node = new TreeNode();

        node.tag = entity;
        node.fileIcon = t;
        node.folderIcon = t;
        node.header = treeNodeHeader;

        _entityArea.children.add(node);

        if (_entityArea.selectedNode == null)
        {
          _entityArea.selectNode(node);
        }
      });
  }

  void _updateEntityUI(EntityViewModel entity)
  {
    _componentArea.accordionItems.clear();

    Futures.wait(entity.components.map((v) => v.ready))
      .then((_) {
        for (View view in entity.components)
          _addComponentPropertyView(view);

          EntityPropertiesViewModel entityViewModel = entity.entityProperties.rootVisual.dataContext;
          TreeNode selected = _entityArea.selectedNode;
          print('Hi ${selected.header}');
          entityViewModel.entityName = selected.header;
          bind(entityViewModel.entityNameProperty, selected.headerProperty);
      });
  }

  void _addComponentPropertyView(PropertiesView view)
  {
    final item = new AccordionItem();
    item.body = view.rootVisual;

    view.headerTemplate
      .chain((value) => Template.deserialize(value))
      .then((template) {
        item.header = template;
      });

    _componentArea.accordionItems.add(item);
  }

  /** Adds an [entityVM] to the application and updates the UI. */
/*
  void addEntity(EntityViewModel entityVM){
    // something should always be selected (_scene is default)
    assert(_currentNode != null);


    entityVM
      .propertyVM
      .setDataContext()
      .chain((_) => Futures.wait(entityVM.propertyVM.propertyViews.getValues().map((v) => v.ready)))
      .chain((_) => Futures.wait([entityVM.fileTemplate, entityVM.folderTemplate]))
      .chain((result) => Futures.wait(result.map((r) => Template.deserialize(r))))
      .then((results){
        // Using the tag property to hold a reference to the entity view model
        // object.
        final node = new TreeNode()
          ..tag = entityVM
          ..fileIcon = results[0]
          ..folderIcon = results[1];

        if (_currentNode != _scene){
          // setup the relationships
          entityVM.parent = _currentNode.tag;
          _currentNode.tag.children.add(entityVM);


        }

        _currentNode.childNodes.add(node);
        _currentNode.childVisibility = Visibility.visible;
        _currentNode = node;

        _updateUITo(_currentNode, entityVM.propertyVM.entityName);
      });
  }


  //---------------------------------------------------------------------
  // UI layout handling
  //---------------------------------------------------------------------

  void _updateUITo(TreeNode node, [String entityName]){
    _componentArea.accordionItems.clear();

    if (node == null || node == _scene || node.tag == null){
      _currentNode = _scene;
      return;
    }

    final evm = node.tag as EntityViewModel;

        evm
        .propertyVM
        .propertyViews
        .forEach((String name, View view){
          final ai = new AccordionItem()
                            ..header = name
                            ..body = view.rootVisual;

          _componentArea.accordionItems.add(ai);
        });

        if (entityName != null){
          // bind the entity name to the treenode header and initialize it.
          bind(evm.propertyVM.entityNameProperty, node.headerProperty);
          evm.propertyVM.entityName = entityName;
        }
    }
*/

  //---------------------------------------------------------------------
  // Canvas handling
  //---------------------------------------------------------------------

  void _canvasLoadedHandler(WebGLCanvas canvas, _)
  {
    _context = canvas.context;

    // Updated the surface dimension to whatever the canvas size is in the DOM
    canvas
      .updateMeasurementAsync
      .then((ElementRect r){
        canvas.surfaceHeight = r.bounding.height;
        canvas.surfaceWidth = r.bounding.width;
      });
  }

  void _frameHandler(_, FrameEventArgs e)
  {
    _context.clearColor(0.0, 0.0, 0.0, 1.0);
    _context.enable(WebGLRenderingContext.DEPTH_TEST);
    _context.depthFunc(WebGLRenderingContext.LEQUAL);
    _context.clear(WebGLRenderingContext.COLOR_BUFFER_BIT|WebGLRenderingContext.DEPTH_BUFFER_BIT);
  }

  void zoidberg(_, __){
    new View
      .fromTemplate("<image sourceuri='web/resources/for_don.jpg' />")
      .ready
      .chain((t){
        final md = new ModalDialog.with("Nobody!", t, ModalDialog.Ok);
        return md.show();
      });
  }
}
