function comparator(ids1,ids2,path)
  
  if nargin < 3,
    path = '';
  end
  
  c1 = class(ids1);
  c2 = class(ids2);
  assert(strcmp(c1,c2),'%s: Incompatible class: %s/%s', path, c1, c2);
  n1 = numel(ids1);
  n2 = numel(ids2);
  assert(n1 == n2,'%s: Incompatible number of elements : %d/%d', path, n1, n2);
  switch class(ids1),
    case 'cell'
      for ii = 1:n1
        comparator(ids1{ii},ids2{ii},sprintf('%s(%d)',path,ii));
      end
    case 'struct'
      f1 = fieldnames(ids1);
      f2 = fieldnames(ids2);
      assert(isequal(f1, f2),'%s: Structures have different fields', path);
      for ii = 1:numel(f1)
        comparator(ids1.(f1{ii}),ids2.(f1{ii}),sprintf('%s/%s',path,f1{ii}));
      end
    case {'char','int32','double'}
      assert(isequal(ids1, ids2),'%s: Fields have different value', path);
  end
  
end