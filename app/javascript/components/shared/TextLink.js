// @flow
import * as React from 'react';

const TextLink = ({ children, ...rest }: { children: ?React.Node }) => (
  <a href="#" {...rest}>
    {children}
  </a>
);

export default TextLink;
